import std.algorithm;
import std.conv;
import std.file;
import std.range;
//import std.regex;
import std.stdio;
import std.string;
import std.uni;

string [] topNames;

string toSnakeCase (string word)
{
	string res;
	foreach (c; word)
	{
		if (isUpper (c) && !res.empty)
		{
			res ~= '_';
		}
		res ~= toLower (c);
	}
	return res;
}

// if future use: won't work for the case A_BCD
string convertSnakeCapsToCamel (string line)
{
	string [] parts;
	bool isIdentifier = false;
	string cur;
	foreach (dchar c; line)
	{
		bool isIdentifierNext = (c.isAlphaNum || c == '_');
		if (isIdentifier != isIdentifierNext)
		{
			parts ~= cur;
			cur = "";
			isIdentifier = isIdentifierNext;
		}
		cur ~= c;
	}
	parts ~= cur;

	string res;
	foreach (part; parts)
	{
		if (part.empty)
		{
			continue;
		}

		bool isIdentifierPart = (part.front.isAlphaNum ||
		    part.front == '_');
		if (!isIdentifierPart)
		{
			res ~= part;
			continue;
		}

		bool isSnakeCaps = (part.length >= 2) &&
		    part[0].isUpper && part[1].isUpper;
		if (!isSnakeCaps)
		{
			res ~= part;
			continue;
		}

		if (part == "PI")
		{
			res ~= part;
			continue;
		}

		string modPart;
		bool isPrevUnderscore = false;
		foreach (c; part)
		{
			if (c == '_')
			{
				isPrevUnderscore = true;
				continue;
			}
			else if (isPrevUnderscore)
			{
				modPart ~= c.toUpper ().text;
			}
			else
			{
				modPart ~= c.toLower ().text;
			}
			isPrevUnderscore = false;
		}
		res ~= modPart;
	}
	return res;
}

bool isCommentLine (string line)
{
	return !line.empty && "/*".canFind (line.stripLeft.front);
}

bool isAttributeLine (string line)
{
	return !line.empty && "@".canFind (line.stripLeft.front);
}

string [] words (string line)
{
	string [] res;
	int wordStart = int.min;
	foreach (int i, c; line ~ " ")
	{
		if (!c.isAlphaNum && c != '_')
		{
			if (wordStart != int.min)
			{
				res ~= line[wordStart..i];
			}
			wordStart = int.min;
		}
		else
		{
			if (wordStart == int.min)
			{
				wordStart = i;
			}
		}
	}
	return res;
}

string [] tokens (string line)
{
	string [] res;
	enum State {White, Id, Op}
	State cur = State.White;
	int pos = 0;
	foreach (int i, c; line ~ " ")
	{
		State next = (c.isAlphaNum || c == '_') ? State.Id :
		    c.isWhite ? State.White : State.Op;
		if (cur != next)
		{
			if (cur != State.White)
			{
				res ~= line[pos..i];
			}
			pos = i;
		}
		cur = next;
	}
	return res;
}

string convertComments (string line)
{
	if (isCommentLine (line))
	{
		string res = line;
		res = res.replace ("<p>", "$(BR)");
		res = res.replace ("<p/>", "$(BR)");
		res = res.replace ("<ul>", "$(UL");
		res = res.replace ("</ul>", ")");
		res = res.replace ("<li>", "$(LI");
		res = res.replace ("</li>", ")");
		if (res.canFind ("@code"))
		{
			res = res.replace ("{@code ", "`");
			res = res.replace ("}", "`");
		}
		res = res.replace ("@return", "Returns:");
		res = res.replace ("@param", "Params:");
		res = res.replace ("@see", "See_Also:");
		return res;
	}
	else
	{
		return line;
	}
}

string convertKeyLines (string line, string curModuleName)
{
	if (line.startsWith ("package"))
	{
		return "module model." ~ curModuleName ~ ";";
	}
	else if (line.canFind ("class"))
	{
		string res = line;
		res = res.replace ("public ", "");
		// we deal with immutability later and differently
		res = res.replace ("final ", "");
		res = res.replace (" extends ", " : ");
		return res;
	}
	else if (line.canFind ("enum"))
	{
		string res = line;
		res = res.replace ("public ", "");
		return res;
	}
	else
	{
		return line;
	}
}

string convertMisc (string line)
{
	string res = line;
	res = res.replace ("public ", "");
	res = res.replace ("private ", "");
	res = res.replace ("final ", "");
	res = res.replace (".0D", ".0");
	res = res.replace ("[]", " []");
	res = res.replace ("(", " (");
	res = res.replace ("  (", " (");
	res = res.replace ("boolean ", "bool ");
	res = res.replace ("String ", "string ");
	while (res.canFind ("Arrays.copyOf"))
	{
		auto parts = res.findSplit ("Arrays.copyOf (");
		string argument = parts[2].until (",").text;
		parts[2].findSkip (")");
		res = parts[0] ~ argument ~ parts[2];
	}
	return res;
}

class Field
{
	string [] lines;
	string [] headComment;
	string name;
	string type;

	void processComments ()
	{
		foreach (ref line; headComment)
		{
			line = line.replace ("Returns: ", "");
		}
	}

	this (string [] inputLines)
	{
		foreach (line; inputLines)
		{
			lines ~= line;
		}
		while (!lines.empty && lines.front.isCommentLine)
		{
			headComment ~= lines.front;
			lines.popFront ();
		}
		if (lines.empty)
		{
			assert (false);
		}
		auto temp = words (lines.front.until (";").text);
		name = temp.filter !(word => word.front.isAlpha).array.back;
		name = name.until (";").text;
		processComments ();
	}

	string [] write ()
	{
		string [] res;
		res ~= headComment;
		res ~= lines;
		return res;
	}
}

class Method
{
	string [] lines;
	string [] headComment;
	string [] headLines;
	string name;
	string type;

	void processComments ()
	{
		string [] res;
		bool foundParams = false;
		foreach (line; headComment)
		{
			if (line.canFind ("Params:"))
			{
				if (!foundParams)
				{
					res ~= "     * Params:";
					foundParams = true;
				}
				auto parts = line.findSplit ("Params: ");
				auto parts2 = parts[2].findSplit (" ");
				line = parts[0] ~ "  " ~ parts2[0] ~ " = " ~
				    parts2[2];
			}
			res ~= line;
		}
		headComment = res;
	}

	void processHeadLines ()
	{
		auto headLine = headLines.join (" ");
		auto headTokens = headLine.tokens;
		assert (headTokens.back == "{");
		headTokens.popBack ();

		headLines.length = 0;
		auto curLine = "   ";
		string curToken;
		do
		{
			curToken = headTokens.front;
			curLine ~= " " ~ curToken;
			headTokens.popFront ();
		}
		while (!curToken.startsWith ("("));

		while (!headTokens.empty && headTokens.front != ")")
		{
			headLines ~= curLine;
			curLine = "       ";
			do
			{
				curToken = headTokens.front;
				if (!"),".canFind (curToken))
				{
					curLine ~= " ";
				}
				curLine ~= curToken;
				headTokens.popFront ();
			}
			while (!"),".canFind (curToken));
		}
		curLine ~= " const";
		headLines ~= curLine;

		foreach (ref line; headLines.drop (1))
		{
			int pos = 0;
			while (!line[pos].isAlpha)
			{
				pos += 1;
				assert (pos < line.length);
			}
			if (line[pos].isUpper || line.canFind ("[]"))
			{
				line = line[0..pos] ~ "immutable " ~
				    line[pos..$];
			}
		}
	}

	this (string [] inputLines)
	{
		foreach (line; inputLines)
		{
			lines ~= line;
		}
		while (!lines.empty && (lines.front.isCommentLine ||
		    lines.front.isAttributeLine))
		{
			if (lines.front.isCommentLine)
			{
				headComment ~= lines.front;
			}
			lines.popFront ();
		}
		if (lines.empty)
		{
			assert (false);
		}
		auto temp = words (lines.front.until ("(").text);
		name = temp[$ - 1];

		int balance = 0;
		while (!lines.empty && balance == 0)
		{
			balance += lines.front.count ("{") -
			    lines.front.count ("}");
			headLines ~= lines.front;
			lines.popFront ();
		}
		assert (!lines.empty &&
		    lines.back.count ("{") == 0 &&
		    lines.back.count ("}") == 1);
		lines.popBack ();
		processHeadLines ();
		processComments ();
	}

	string [] write ()
	{
		string [] res;
		res ~= headComment;
		res ~= headLines;
		res ~= "    {";
		res ~= lines;
		res ~= "    }";
		return res;
	}
}

class Class
{
	string [] lines;
	string [] headComment;
	string headLine;
	Field [] fields;
	Method [] methods;
	string name;
	string preDeclaration;
	string postDeclaration;

	void process ()
	{
		int balance = 0;
		int balance2 = 0;
		int start = int.min;
		foreach (int i, line; lines)
		{
			if (line.empty || line.isCommentLine ||
			    line.isAttributeLine)
			{
				continue;
			}
			balance += line.count ("{") - line.count ("}");
			balance2 += line.count ("(") - line.count (")");
			if (balance == 0 && balance2 == 0 &&
			    line.endsWith (";"))
			{
				start = i;
			}
			if (start == int.min && line.canFind ("("))
			{
				start = i;
			}
			if (balance == 0 && balance2 == 0 &&
			    start != int.min)
			{
				int pos = start;
				while (start > 0 &&
				    lines[start - 1].isCommentLine)
				{
					start -= 1;
				}
				int end = cast (int) (i + 1);
				if (lines[pos].endsWith (";"))
				{
					fields ~= new Field
					    (lines[start..end]);
				}
				else
				{
					methods ~= new Method
					    (lines[start..end]);
				}
				start = int.min;
			}
		}

		foreach (curMethod; methods)
		{
			if (curMethod.name == name)
			{
				auto parts = curMethod.headLines.front
				    .findSplit (name);
				curMethod.headLines.front =
				    parts[0] ~ "this" ~ parts[2];
				curMethod.name = "this";
				curMethod.headLines.back =
				    curMethod.headLines.back
				    .until (" const").text;
			}
			foreach (prefix; ["is", "get", "set"])
			{
				if (curMethod.name.startsWith (prefix))
				{
					auto fieldName = curMethod.name;
					findSkip (fieldName, prefix);
					fieldName = fieldName[0].toLower.text ~
					    fieldName[1..$];
					foreach (curField; fields)
					{
						if (curField.name == fieldName)
						{
							curField.headComment =
							    curMethod
							    .headComment;
							curMethod.name = "***";
						}
					}
				}
			}
		}
		methods = methods
		    .filter !(curMethod => curMethod.name != "***").array;

		foreach (curField; fields)
		{
			debug {writeln ("field ", curField.name);}
		}
		foreach (curMethod; methods)
		{
			debug {writeln ("method ", curMethod.name);}
		}
	}

	this (string [] inputLines)
	{
		foreach (line; inputLines)
		{
			lines ~= line;
		}
		while (!lines.empty && lines.front.isCommentLine)
		{
			headComment ~= lines.front;
			lines.popFront ();
		}
		if (lines.empty)
		{
			assert (false);
		}
		preDeclaration = lines.front.until ("class").text;
		name = lines.front;
		findSkip (name, "class ");
		postDeclaration = name;
		name = name.until (" ").text;
		postDeclaration = postDeclaration.find (" ").until (" {").text;
		headLine = preDeclaration ~ "immutable class " ~ name ~
		    postDeclaration;
		assert (lines.front.count ("{") == 1 &&
		    lines.front.count ("}") == 0);
		assert (lines.back.count ("{") == 0 &&
		    lines.back.count ("}") == 1);
		lines.popFront ();
		lines.popBack ();
		process ();
		debug {writeln (headLine);}
	}

	string [] write ()
	{
		string [] res;
		res ~= headComment;
		res ~= headLine;
		res ~= "{";
		res ~= "nothrow pure @safe @nogc:";
		res ~= "";
		foreach (curField; fields)
		{
			res ~= curField.write ();
		}
		foreach (curMethod; methods)
		{
			res ~= "";
			res ~= curMethod.write ();
		}
		res ~= "}";
		return res;
	}
}

class Enum
{
	string [] lines;
	string [] headComment;
	string headLine;
	string name;

	void process ()
	{
		// enum is good as it is
	}

	this (string [] inputLines)
	{
		foreach (line; inputLines)
		{
			lines ~= line;
		}
		while (!lines.empty && lines.front.isCommentLine)
		{
			headComment ~= lines.front;
			lines.popFront ();
		}
		if (lines.empty)
		{
			assert (false);
		}
		name = lines.front;
		findSkip (name, "enum ");
		name = name.until (" ").text;
		headLine = "enum " ~ name ~ " : byte";
		assert (lines.front.count ("{") == 1 &&
		    lines.front.count ("}") == 0);
		assert (lines.back.count ("{") == 0 &&
		    lines.back.count ("}") == 1);
		lines.popFront ();
		lines.popBack ();
		process ();
		debug {writeln (headLine);}
	}

	string [] write ()
	{
		string [] res;
		res ~= headComment;
		res ~= headLine;
		res ~= "{";
		res ~= lines;
		res ~= "}";
		res ~= "";
		return res;
	}
}

string [] process (string [] inputLines, string curName, string curModuleName)
{
	Enum curEnum;
	Class curClass;
	int balance = 0;
	int start = int.min;
	foreach (int i, line; inputLines)
	{
		if (line.empty || line.isCommentLine)
		{
			continue;
		}
		balance += line.count ("{") - line.count ("}");
		if (line.canFind ("module"))
		{
			continue;
		}
		else if (line.canFind ("enum"))
		{
			start = i;
		}
		else if (line.canFind ("class"))
		{
			start = i;
		}
		if (balance == 0 && start != int.min)
		{
			int pos = start;
			while (start > 0 &&
			    inputLines[start - 1].isCommentLine)
			{
				start -= 1;
			}
			int end = cast (int) (i + 1);
			if (inputLines[pos].canFind ("enum"))
			{
				curEnum = new Enum (inputLines[start..end]);
			}
			else if (inputLines[pos].canFind ("class"))
			{
				curClass = new Class (inputLines[start..end]);
			}
			else
			{
				assert (false);
			}
			start = int.min;
		}
	}

	string [] res;
	if (curEnum !is null)
	{
		res = curEnum.write ();
	}
	else if (curClass !is null)
	{
		res = curClass.write ();
	}
	else
	{
		assert (false);
	}
	return res;
}

void translateFile (string fileName)
{
	auto input = File (fileName, "rt");
	auto curName = fileName
	    .replace ("../java/model/", "")
	    .replace (".java", "");
	auto curModuleName = curName
	    .toSnakeCase;
	string [] inputLines;
	foreach (string line; input.byLineCopy ())
	{
		inputLines ~= line;
	}

	inputLines = inputLines
	    // remove Java-specific attributes
	    .filter !(line => !line.startsWith ("@SuppressWarnings"))
	    // remove Java-specific imports
	    .filter !(line => !line.startsWith ("import"))
	    // remove trailing whitespace
	    .map !(line => line.stripRight)
	    // globally convert all-uppercase names
	    .map !(line => line.convertSnakeCapsToCamel)
	    // convert miscellaneous differences
	    .map !(line => line.convertMisc)
	    // globally convert comments
	    .map !(line => line.convertComments)
	    // convert key lines
	    .map !(line => line.convertKeyLines (curModuleName))
	    .array;

	bool [string] mark;
	bool hasMath = false;
	foreach (line; inputLines)
	{
		auto cur = words (line);
		foreach (name; topNames)
		{
			if (cur.canFind (name))
			{
				mark[name] = true;
			}
		}
		if (cur.canFind ("atan2"))
		{
			hasMath = true;
		}
	}

	auto output = File ("../model/" ~ curModuleName ~ ".d", "wt");

	output.writeln (inputLines.front);
	output.writeln;
	if (mark.length > 1 || hasMath)
	{
		foreach (k, v; mark)
		{
			if (k != curName)
			{
				output.writeln ("import model.",
				    k.toSnakeCase, ";");
			}
		}
		if (hasMath)
		{
			output.writeln ("import std.math;");
		}
		output.writeln;
	}
	inputLines = process (inputLines, curName, curModuleName);

	foreach (line; inputLines)
	{
		output.writeln (line);
	}
}

void main ()
{
	auto dir = dirEntries ("../java/model/", SpanMode.shallow).array;

	foreach (name; dir)
	{
		topNames ~= name
		    .replace ("../java/model/", "")
		    .replace (".java", "");
	}
	sort (topNames);

	foreach (name; dir)
	{
		writeln (name);
		stdout.flush ();
		translateFile (name);
	}

	auto output = File ("../model/package.d", "wt");
	output.writeln ("module model;");
	output.writeln;
	foreach (name; topNames)
	{
		output.writeln ("public import model.", name.toSnakeCase, ";");
	}
}
