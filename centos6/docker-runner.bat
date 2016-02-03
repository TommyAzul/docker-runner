@echo off
setlocal enabledelayedexpansion

set _BIN=%0
set DEBUG=
set LANG=en
set OPTIONS=
set PARAMS=
set COMMANDS=

if "%VBOX_MSI_INSTALL_PATH:~-1%" == "\" set VBOX_DIR=%VBOX_MSI_INSTALL_PATH:~0,-1%
set VBOX="%VBOX_DIR%"\VBoxManage.exe
set CONF=bin\docker-runner.conf

set _DOCKER_RUNNER_PATH=d:\VM\Docker
set _DOCKER_RUNNER_WEBAPPS_PATH=d:\VM\webapps

set PROJECT=
set CPU=2
set MEM=2048
set NET=

::
:: Set PROJECT name from current dir
::
for %%I in (%~f0) do set _DIRNAME=%%~dpI
set DIRNAME=%_DIRNAME:~0,-1%
for %%I in (%DIRNAME%) do set BASENAME=%%~nxI
set PROJECT=%BASENAME%

::
:: Set language
:: japanese code page is 932.
::
for /f "usebackq tokens=2 delims=:" %%L in (`chcp`) do set code_page=%%L
set code_page=%code_page: =%
if "%code_page%" == "932" set LANG=ja

::
:: Set install path
::
if "%DOCKER_RUNNER_PATH%" == "" set DOCKER_RUNNER_PATH=%_DOCKER_RUNNER_PATH%
if "%DOCKER_RUNNER_WEBAPPS_PATH%" == "" set DOCKER_RUNNER_WEBAPPS_PATH=%_DOCKER_RUNNER_WEBAPPS_PATH%


call bin\functions.bat %*


if NOT "%DEBUG%" == "" (
    echo;
    echo OPTIONS  : %OPTIONS%
    echo PARAMS   : %PARAMS%
    echo COMMANDS : %COMMANDS%
    echo PROJECT  : %PROJECT%
    echo CPU      : %CPU%
    echo MEMORY   : %MEM%
    echo NETWORK  : %NET%
    echo LANG     : %LANG%
    echo;
)
if "%COMMANDS%" == "" (
    echo;
    echo It doesn't have any COMMANDS.
    echo Usage: %_BIN% [OPTION] COMMAND
    echo;
)
if "%PROJECT%" == "" (
    echo;
    echo It need project name as option.
    echo;
)
exit /b
endlocal
