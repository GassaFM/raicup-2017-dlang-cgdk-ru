module remote_process_client;

import std.bitmanip;
import std.conv;
import std.exception;
import std.range;
import std.socket;
import std.stdio;
import std.string;
import std.traits;
import std.typecons;

import model;

alias I (alias T) = T;

template WriteContents (T)
{
    string Impl ()
    {
        string res;
        alias member = I !(__traits (getMember, T, "__ctor"));
        alias types = ParameterTypeTuple !(member);
        alias names = ParameterIdentifierTuple !(member);
        foreach (i, type; types)
        {
            immutable string line = "write !(const " ~
                type.stringof ~ ") (t." ~ names[i] ~ ");\n";
            res ~= line;
        }
        return res;
    }

    immutable string WriteContents = Impl ();
}

template ReadContents (T)
{
    string Impl ()
    {
        string res;
        alias member = I !(__traits (getMember, T, "__ctor"));
        alias types = ParameterTypeTuple !(member);
        alias names = ParameterIdentifierTuple !(member);
        foreach (i, type; types)
        {
            immutable string line = "auto " ~ names[i] ~
                " = read !(" ~ type.stringof ~ ") ();\n";
            res ~= line;
        }
        return res;
    }

    immutable string ReadContents = Impl ();
}

template CallConstructor (T)
{
    string Impl ()
    {
        alias member = I !(__traits (getMember, T, "__ctor"));
        alias names = ParameterIdentifierTuple !(member);
        return "new immutable T (" ~ [names].join (", ") ~ ")";
    }

    immutable string CallConstructor = Impl ();
}

enum MessageType : byte
{
    unknownMessage,
    gameOver,
    authenticationToken,
    teamSize,
    protocolVersion,
    gameContext,
    playerContext,
    moveMessage,
}

class RemoteProcessClient
{
public:
    this (string host, string port)
    {
        Address addr = getAddress (host, port)[0];
        socket = new Socket (addr.addressFamily, SocketType.STREAM);
        socket.setOption (SocketOptionLevel.TCP,
            SocketOption.TCP_NODELAY, true);
        socket.setOption (SocketOptionLevel.SOCKET,
            SocketOption.RCVBUF, 1 << 12);
        socket.connect (addr);
    }

    void writeToken (string token)
    {
        write (MessageType.authenticationToken);
        write (token);
    }

    int readTeamSize ()
    {
        enforce (read !(MessageType) == MessageType.teamSize);
        return read !(int);
    }

    void writeProtocolVersion ()
    {
        write (MessageType.protocolVersion);
        write !(int) (1);
    }

    auto readGameContextMessage ()
    {
        auto messageType = read !(MessageType) ();
        enforce (messageType == MessageType.gameContext);

        return read !(immutable Game) ();
    }

    auto readPlayerContextMessage ()
    {
        auto messageType = read !(MessageType) ();
        if (messageType == MessageType.gameOver)
        {
            return null;
        }
        enforce (messageType == MessageType.playerContext);

        return read !(immutable PlayerContext) ();
    }

    void writeMoveMessage (Move move)
    {
        write (MessageType.moveMessage);

        write !(Move) (move);
    }

    void close ()
    {
        socket.close;
    }

private:
    Socket socket;

    Rebindable !(immutable Player []) playersArrayCache;
    Rebindable !(immutable Facility []) facilitiesArrayCache;
    Rebindable !(immutable TerrainType [] []) terrainType2DArrayCache;
    Rebindable !(immutable WeatherType [] []) weatherType2DArrayCache;

    Rebindable !(immutable Player) [long] playerCache;
    Rebindable !(immutable Facility) [long] facilityCache;

    enum ReadMode : byte {empty = 0, normal = 1, useCache = 127};

    auto read (T) ()
        if (is (T == class))
    {
        debug (io) {writeln (">read " ~ T.stringof);}
        debug (io) {scope (success) {writeln ("<read " ~ T.stringof);}}

        auto readMode = read !(ReadMode) ();
        if (readMode == ReadMode.empty)
        {
            return null;
        }

        static if (is (Unqual !(T) == World))
        { // custom read: World has caching for some member arrays
//            pragma (msg, ReadContents !(T));
            mixin (ReadContents !(T)
                .replace ("auto terrainByCellXY = " ~
                "read !(immutable(TerrainType[][])) ();\n",
                "if (terrainType2DArrayCache is null) {" ~
                "terrainType2DArrayCache = " ~
                "read !(immutable(TerrainType[][])) ();}\n")
                .replace ("auto weatherByCellXY = " ~
                "read !(immutable(WeatherType[][])) ();\n",
                "if (weatherType2DArrayCache is null) {" ~
                "weatherType2DArrayCache = " ~
                "read !(immutable(WeatherType[][])) ();}\n"));

            if (players !is null)
            {
                playersArrayCache = rebindable (players);
            }
            if (facilities !is null)
            {
                facilitiesArrayCache = rebindable (facilities);
            }

            return mixin (CallConstructor !(T)
                .replace ("players", "playersArrayCache")
                .replace ("facilities", "facilitiesArrayCache")
                .replace ("terrainByCellXY", "terrainType2DArrayCache")
                .replace ("weatherByCellXY", "weatherType2DArrayCache"));
        }
        else static if (is (Unqual !(T) == Player))
        { // custom read: Player may be cached
            long curId;
            if (readMode == ReadMode.normal)
            {
                mixin (ReadContents !(T));

                auto temp = mixin (CallConstructor !(T));
                curId = temp.id;
                playerCache[curId] = temp;
            }
            else if (readMode == ReadMode.useCache)
            {
                curId = read !(long) ();
            }
            else
            {
                assert (false);
            }
            return cast (immutable Player) playerCache[curId];
        }
        else static if (is (Unqual !(T) == Facility))
        { // custom read: Facility may be cached
            long curId;
            if (readMode == ReadMode.normal)
            {
                mixin (ReadContents !(T));

                auto temp = mixin (CallConstructor !(T));
                curId = temp.id;
                facilityCache[curId] = temp;
            }
            else if (readMode == ReadMode.useCache)
            {
                curId = read !(long) ();
            }
            else
            {
                assert (false);
            }
            return cast (immutable Facility) facilityCache[curId];
        }
        else
        { // generic read for model classes
            mixin (ReadContents !(T));
            return mixin (CallConstructor !(T));
        }
    }

    void write (T) (T t)
        if (is (T == class))
    {
        debug (io) {writeln (">write " ~ T.stringof);}
        debug (io) {scope (success) {writeln ("<write " ~ T.stringof);}}
        write !(bool) (true);

        static if (is (Unqual !(T) == Move))
        { // custom write: Move does not have an all-fields constructor
            write !(ActionType) (t.action);
            write !(int) (t.group);
            write !(double) (t.left);
            write !(double) (t.top);
            write !(double) (t.right);
            write !(double) (t.bottom);
            write !(double) (t.x);
            write !(double) (t.y);
            write !(double) (t.angle);
            write !(double) (t.maxSpeed);
            write !(double) (t.maxAngularSpeed);
            write !(VehicleType) (t.vehicleType);
            write !(long) (t.facilityId);
        }
        else
        { // generic write for model classes
//            pragma (msg, WriteContents !(T));
            mixin (WriteContents !(T));
        }
    }

    auto read (T : T [num], ulong num) ()
    {
        int len = read !(int) ();
        enforce (len == num);

        T [num] ret = void;
        foreach (ref val; ret)
        {
            val = read !(T) ();
        }
        return ret;
    }

    auto read (T : string) ()
    {
        int len = read !(int) ();
        enforce (len >= 0);
        return cast (string) (readBytesRuntime (len).idup);
    }

    void write (T : string) (T value)
    {
        write !(int) (cast (int) (value.length));
        writeBytes (cast (ubyte []) value);
    }

    auto read (T : T []) ()
    {
        debug (io) {writeln ("reading array of ", T.stringof); stdout.flush;}
        int len = read !(int) ();
        if (len < 0)
        {
            return null;
        }
        else
        {
            T [] ret;
            ret.reserve (len);
            foreach (i; 0..len)
            {
                ret ~= read !(T) ();
            }
            return ret;
        }
    }

    void write (T : T []) (T [] value)
    {
        if (value is null)
        {
            write !(int) (-1);
        }
        else
        {
            write !(int) (cast (int) (value.length));
            foreach (elem; value)
            {
                write !(T) (elem);
            }
        }
    }

    auto read (T) ()
        if (!is (T == class))
    {
        return littleEndianToNative !(T) (readBytes !(T.sizeof));
    }

    void write (T) (T value)
        if (!is (T == class))
    {
        writeBytes (nativeToLittleEndian (value));
    }

    auto readBytes (size_t byteCount) ()
    {
        ubyte [byteCount] bytes = readBytesRuntime (byteCount);
        return bytes;
    }

    auto readBytesRuntime (size_t byteCount)
    {
        auto bytes = new ubyte [byteCount];
        size_t offset = 0;
        while (offset < byteCount)
        {
            debug (io) {writeln ("in ", offset, " ", byteCount);}
            offset += socket.receive (bytes[offset..bytes.length]);
        }
        debug (io) {writeln ("read: ", bytes);}
        return bytes;
    }

    void writeBytes (const ubyte [] bytes)
    {
        size_t offset = 0;
        while (offset < bytes.length)
        {
            auto sent = socket.send (bytes[offset..bytes.length]);
            enforce (sent > 0);
            offset += sent;
        }
        debug (io) {writeln ("write: ", bytes);}
    }
}
