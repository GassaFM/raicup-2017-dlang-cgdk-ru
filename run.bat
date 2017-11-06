rem @echo off

rem call compile-d.bat

if "%LOCAL_RUNNER_HOME%" == "" (
    :: Change the next line to your local runner's working directory
    :: or pass it via an environment variable
    set LOCAL_RUNNER_HOME=C:\some\path\local-runner-ru\
)

pushd %LOCAL_RUNNER_HOME%
call local-runner.bat
popd
:: sleep 2 (http://stackoverflow.com/a/1672349)
ping -n 3 127.0.0.1 >nul
MyStrategy
