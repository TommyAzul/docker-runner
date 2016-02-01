set i=0
set k=0
set option=
set value=

for %%p in (%*) do (
    set /a i+=1
    set argv=%%~p

    if "!argv:~0,1!" == "-" (
        if NOT "!option!" == "" (
            call :setOptions !option! & if errorlevel 1 (
                echo OPTION error: it doesn't have this option "!option!"
                exit /b
            )
            set option=
        )
        set option=!argv:-=!
        set /a k=!i!+1
    ) else (
        set value=!argv!
        if !i! NEQ !k! (
            call :execCommand !argv! & if errorlevel 1 (
                echo CMD error: it doesn't have this command "!argv!"
                exit /b
            )
            exit /b
        )
    )

    if !i! EQU !k! (
        set k=0
        set value=!argv!
        call :setParameters !option! !value! & if errorlevel 1 (
            call :setOptions !option! & if errorlevel 1 (
                echo PARAM error: it doesn't have this param "!option!"
                echo OPTION error: it doesn't have this option "!option!"
                exit /b
            )
            call :execCommand !value! & if errorlevel 1 (
                echo CMD error: it doesn't have this command "!value!"
                exit /b
            )
            exit /b
        )
        set option=
        set value=
    )
)

if "%*" == "" (
    call :execCommand help
)


:setOptions
    if "%1" == "v" (
        set DEBUG=0
    ) else if "%1" == "debug" (
        set DEBUG=0
    ) else if "%1" == "verbose" (
        set DEBUG=0
    ) else if "%1" == "en" (
        set LANG=en
    ) else if "%1" == "english" (
        set LANG=en
    ) else if "%1" == "ja" (
        set LANG=ja
    ) else if "%1" == "japanese" (
        set LANG=ja
    ) else (
        exit /b 1
    )
    set OPTIONS=%OPTIONS% %1
exit /b 0


:setParameters
    if "%2" == "" (
        echo PARAM error: it doesn't have any value.
        exit /b 1
    )

    if "%1" == "p" (
        set PROJECT=%2
    ) else if "%1" == "project" (
        set PROJECT=%2
    ) else if "%1" == "cpu" (
        set CPU=%2
    ) else if "%1" == "cpucount" (
        set CPU=%2
    ) else if "%1" == "mem" (
        set MEM=%2
    ) else if "%1" == "memory" (
        set MEM=%2
    ) else if "%1" == "memories" (
        set MEM=%2
    ) else if "%1" == "net" (
        set NET=%2
    ) else if "%1" == "network" (
        set NET=%2
    ) else if "%1" == "ip" (
        set NET=%2
    ) else if "%1" == "ipaddress" (
        set NET=%2
    ) else if "%1" == "lang" (
        if "%2" == "en" set LANG=en
        if "%2" == "ja" set LANG=ja
        if "%2" == "english"  set LANG=en
        if "%2" == "japanese" set LANG=ja
    ) else if "%1" == "language" (
        if "%2" == "en" set LANG=en
        if "%2" == "ja" set LANG=ja
        if "%2" == "english"  set LANG=en
        if "%2" == "japanese" set LANG=ja
    ) else (
        exit /b 1
    )
    set PARAMS=%PARAMS% %1=%2
exit /b 0


:execCommand
    if "%1" == "create" (
        call :dockerMachineCreate
        call :setSharedDirs
        call :dockerMachineStart
    ) else if "%1" == "delete" (
        call :dockerMachineDelete
    ) else if "%1" == "rm" (
        call :dockerMachineDelete
    ) else if "%1" == "share" (
        call :setSharedDirs
        call :dockerMachineStart
        call :showInstructions
    ) else if "%1" == "start" (
        call :dockerMachineStart
    ) else if "%1" == "restart" (
        call :dockerMachineStop
        call :dockerMachineStart
    ) else if "%1" == "login" (
        call :showInstructions
    ) else if "%1" == "stop" (
        call :dockerMachineStop
    ) else if "%1" == "status" (
        call :dockerMachineStatus
    ) else if "%1" == "ls" (
        call :dockerMachineStatus
    ) else if "%1" == "help" (
        call bin\helps.%LANG%.bat
    ) else (
        exit /b 1
    )
    set COMMANDS=%COMMANDS% %1
exit /b 0


::
:: Create docker machine with virtualbox
::
:dockerMachineCreate
    if NOT "%DEBUG%" == "" (
        echo docker-machine create
        echo     -d virtualbox
        echo     --virtualbox-cpu-count "%CPU%"
        echo     --virtualbox-memory "%MEM%"
        if NOT "%NET%" == "" (
            echo     --virtualbox-hostonly-cidr "%NET%/24"
        )
        echo     %PROJECT%
    )
    if NOT "%NET%" == "" (
        docker-machine create ^
            -d virtualbox ^
            --virtualbox-cpu-count "%CPU%" ^
            --virtualbox-memory "%MEM%" ^
            --virtualbox-hostonly-cidr "%NET%/24" ^
            %PROJECT%
    ) else (
        docker-machine create ^
            -d virtualbox ^
            --virtualbox-cpu-count "%CPU%" ^
            --virtualbox-memory "%MEM%" ^
            %PROJECT%
    )
    timeout /t 3 /nobreak >nul
exit /b 0


::
:: Delete docker machine
::
:dockerMachineDelete
    if NOT "%DEBUG%" == "" (
        echo;
        echo docker-machine rm %PROJECT%
        echo;
    )
    docker-machine rm %PROJECT%
exit /b 0


::
:: Start docker machine
::
:dockerMachineStart
    if NOT "%DEBUG%" == "" (
        echo;
        echo docker-machine start %PROJECT%
        echo for /f "tokens=*" %%i in ^('docker-machine env %PROJECT% --shell cmd'^) do %%i
        echo docker-machine ls
        echo;
    )
    echo;
    docker-machine start %PROJECT%
    timeout /t 3 /nobreak >nul
    for /f "tokens=*" %%i in ('docker-machine env %PROJECT% --shell cmd') do %%i
    echo;
    docker-machine ls
    echo;
exit /b 0


::
:: Stop docker machine
::
:dockerMachineStop
    if NOT "%DEBUG%" == "" (
        echo;
        echo docker-machine stop %PROJECT%
        echo docker-machine ls
        echo;
    )
    for /f "tokens=*" %%i in ('docker-machine env %PROJECT% --shell cmd') do %%i
    docker-machine stop %PROJECT%
    echo;
    docker-machine ls
    echo;
exit /b 0


::
:: Show docker machine status
::
:dockerMachineStatus
    if NOT "%DEBUG%" == "" (
        echo;
        echo docker-machine ls
    )
    echo;
    for /f "tokens=*" %%i in ('docker-machine env %PROJECT% --shell cmd') do %%i
    docker-machine ls
    echo;
exit /b 0


::
:: Set shared directories in virtualbox
::
:setSharedDirs
    set i=0
    set SHOW=9999999999
    set automount=
    set VBOX=%VBOX:\\=\%

    if NOT "%DEBUG%" == "" (
        echo;
        echo docker-machine stop %PROJECT%
        echo;
    )
    docker-machine stop %PROJECT%

    for /f "eol=# tokens=1,2,3" %%I in (%CONF%) do (
        set /a i+=1

        if "%%I" == "[shared]" (
            set /a SHOW=!i!+1
        )
        if !i! GEQ !SHOW! (
            set _name=%%I
            set _hostpath=%%J
            set _automount=%%K

            set name=!_name:@@PROJECT@@=%PROJECT%!
            set hostpath=!_hostpath:@@PROJECT@@=%PROJECT%!
            set hostpath=!hostpath:@@DOCKER_RUNNER_PATH@@=%DOCKER_RUNNER_PATH%!
            set hostpath=!hostpath:@@DOCKER_RUNNER_WEBAPPS_PATH@@=%DOCKER_RUNNER_WEBAPPS_PATH%!
            if !_automount! EQU 1 set automount=--automount

            if NOT "%DEBUG%" == "" (
                echo %VBOX% sharedfolder add %PROJECT%
                echo        --hostpath "!hostpath!"
                echo        --name "!name!" !automount!
                echo;
            )
            %VBOX% sharedfolder add %PROJECT% --hostpath "!hostpath!" --name "!name!" !automount!
        )
    )
    timeout /t 3 /nobreak >nul
exit /b 0


::
:: Instructions what to do next
::
:showInstructions
    if NOT "%DEBUG%" == "" (
        echo;
        echo for /f "tokens=*" %%i in ^('docker-machine env %PROJECT% --shell cmd'^) do %%i
        echo docker-machine ssh %PROJECT%
        echo;
    )
    echo;
    echo [Next Instructions]
    echo -----------------------------------------
    echo docker-runner --help
    echo docker-runner status
    echo docker-runner start php*
    echo -----------------------------------------
    echo;
    for /f "tokens=*" %%i in ('docker-machine env %PROJECT% --shell cmd') do %%i
    for /f "usebackq tokens=*" %%i IN (`call cscript //nologo bin\gmtime.vbs`) DO set GMT=%%i

    set _cmd="[ -d /mnt/%PROJECT% ] || sudo mkdir -p /mnt/%PROJECT%;" ^
             "sudo mount -t vboxsf -o defaults,uid=1000,gid=50,dmode=755,fmode=644 \"%PROJECT%\" /mnt/%PROJECT%;" ^
             "cd /mnt/%PROJECT% && ash docker-runner.sh setup;" ^
             "[ -z \"$(grep LANGUAGE ~/.ashrc)\" ]" ^
             "    && echo >> ~/.ashrc" ^
             "    && echo 'export LANGUAGE=%LANG%' >> ~/.ashrc" ^
             "    || sed -r 's/LANGUAGE=.+/LANGUAGE=%LANG%/g' -i.ashrc ~/.ashrc;" ^
             "[ -z \"$(grep GMT ~/.ashrc)\" ]" ^
             "    && echo 'export GMT=%GMT%' >> ~/.ashrc" ^
             "    || sed -r 's/GMT=.+/GMT=%GMT%/g' -i.ashrc ~/.ashrc;"

    docker-machine ssh %PROJECT% %_cmd%
    docker-machine ssh %PROJECT%
exit /b 0
