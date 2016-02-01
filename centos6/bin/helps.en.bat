echo;
echo   USAGE
echo     %_BIN% [OPTION] COMMAND
echo;
echo   OPTION
echo     -en, --en, --english, --lang=en
echo       Set help messages language to English.
echo       You can select English or Japanese only.
echo       Default: English
echo;
echo     -ja, --ja, --japanese, --lang=ja
echo       Set help messages language to Japanese.
echo       You can select English or Japanese only.
echo;
echo     -v, --debug
echo       Set debug mode on.
echo;
echo     --cpu, --cpu-count [number]
echo       Set CPU count number to use docker machine.
echo       Effective only for create command to create new docker machine.
echo;
echo     --mem, --memory [number(MB)]
echo       Set usage memory to use docker machine.
echo       Effective only for create command to create new docker machine.
echo;
echo     --net, --network [ip]
echo       Set host only network adapter's ip address.
echo       Global ip for docker machine is always statically
echo       from 192.168.xx.100 to 192.168.xx.254. Depending on DHCP which ip
echo       address will be used.
echo       Effective only for create command to create new docker machine.
echo;
echo   COMMAND
echo     help
echo       Show usage this batch.
echo;
echo     create
echo       Create docker machine and setup shared directories for virtualbox.
echo       Start docker machine.
echo;
echo     delete, rm
echo       Delete docker machine.
echo;
echo     share
echo       Setup shared directories for virtualbox. Settings are at [shared]
echo       section in "bin\docker-runner.conf"
echo       Start docker machine.
echo;
echo     start
echo       Start docker machine.
echo;
echo     login
echo       Login to docker machine.
echo;
echo     stop
echo       Stop docker machine.
echo;
echo     restart
echo       restart docker machine.
echo;
echo     status, ls
echo       Show docker machine status.
echo;
