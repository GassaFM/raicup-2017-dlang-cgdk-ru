rem @echo off

set name=MyStrategy

if not exist my_strategy.d (
    echo Unable to find my_strategy.d > compilation.log
    exit 1
)

del /F /Q %name%.exe

set COMPILER_PATH="

if "%DMD_HOME%" neq "" (
    if exist "%DMD_HOME%\windows\bin\dmd.exe" (
        set COMPILER_PATH="%DMD_HOME%\windows\bin\"
    )
)

SetLocal EnableDelayedExpansion EnableExtensions

set FILES=

for %%i in (*.d) do (
    set FILES=!FILES! %%i
)

for %%i in (model\*.d) do (
    set FILES=!FILES! %%i
)

call "%COMPILER_PATH:"=%dmd" -O -release -inline -boundscheck=off -L/STACK:268435456 -wi !FILES! -of%name% 2>compilation.log
