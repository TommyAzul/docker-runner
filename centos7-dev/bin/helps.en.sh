#!/bin/ash

usage() {
    echo
    echo -e "  \033[1mUSAGE\033[0m"
    echo -e "    $0 [\033[4mOPTION\033[0m] \033[4mCMD SERVICE\033[0m[ arg1 arg2 ...]"
    echo
    echo -e "  \033[1mOPTION\033[0m"
    echo -e "    \033[4m-en, --en, --english, --lang=en\033[0m"
    echo -e "      Set help messages language to English."
    echo -e "      You can select English or Japanese only."
    echo -e "      Default: English"
    echo
    echo -e "    \033[4m-ja, --ja, --japanese, --lang=ja\033[0m"
    echo -e "      Set help messages language to Japanese."
    echo -e "      You can select English or Japanese only."
    echo
    echo -e "    \033[4m-v, --verbose, --debug\033[0m"
    echo -e "      Set debug mode on."
    echo
    echo -e "    \033[4m--message=\"commit message\", --msg=\"commit message\"\033[0m"
    echo -e "      Set this option when you save running service as a docker image."
    echo
    echo -e "  \033[1mCMD\033[0m"
    echo -e "    \033[4msetup, --setup\033[0m"
    echo -e "      Install or update latest docker-compose, and set auto mount file."
    echo -e "       - /var/lib/boot2docker/docker-compose"
    echo -e "       - /var/lib/boot2docker/bootlocal.sh"
    echo -e "       - /var/lib/boot2docker/bootsync.sh"
    echo
    echo -e "    \033[4mbuild, --build\033[0m"
    echo -e "      Create docker images, for starters."
    echo
    echo -e "    \033[4mstart, --start\033[0m"
    echo -e "      Start service and storage containers including dependent"
    echo -e "      service, and if it doesn't exist docker images,"
    echo -e "      it creates them automatically."
    echo
    echo -e "    \033[4mlogin, --login\033[0m"
    echo -e "      Login to running service or storage container."
    echo
    echo -e "    \033[4mstop, --stop\033[0m"
    echo -e "      Stop and delete service containers, not including storage containers."
    echo -e "      If you install additional binary packages, it will be deleted."
    echo -e "      Save service containers as images if you want to keep them as current."
    echo -e "      ex) docker-runner --save-as-images php56"
    echo
    echo -e "    \033[4mstatus, --status\033[0m"
    echo -e "      Show docker container status."
    echo -e "      show: docker images, docker ps -a, docker stats"
    echo
    echo -e "    \033[4mrestart, --restart\033[0m"
    echo -e "      Stop and delete service containers, not including storage containers,"
    echo -e "      and start them including every dependent services."
    echo
    echo -e "    \033[4mrefresh, --refresh\033[0m"
    echo -e "      Stop and delete service containers including storage containers."
    echo -e "      Start them including every dependent services."
    echo
    echo -e "    \033[4mrebuild, --rebuild\033[0m"
    echo -e "      Stop and delete service containers, and delete images including storages."
    echo -e "      Rebuild services and storages."
    echo
    echo -e "    \033[4mhelp, --help\033[0m"
    echo -e "      Show this usage."
    echo -e "      ex) docker-runner -en help"
    echo
    echo -e "    \033[4m--delete-storages\033[0m"
    echo -e "      Stop and delete service containers including storage containers."
    echo -e "      This is similar to refresh command, but this won't start anything."
    echo
    echo -e "    \033[4m--delete-images\033[0m"
    echo -e "      Stop and delete service containers including storage containers."
    echo -e "      Delete service and storage images."
    echo -e "      It is possible to delete base image(centos/dev) too."
    echo
    echo -e "    \033[4m--backup-storages\033[0m"
    echo -e "      Backup storage data into tar file."
    echo
    echo -e "    \033[4m--restore-storages\033[0m"
    echo -e "      Restore storage data from latest tar backup file."
    echo -e "      This is not available to set multiple services."
    echo -e "      If it need restore from specific file, set datetime of partial file name."
    echo -e "      ex) docker-runner --restore-storages php56 20160101.101024"
    echo
    echo -e "    \033[4m--save-as-images\033[0m"
    echo -e "      Save running service container as a docker image. (docker commit)"
    echo -e "      ex) docker-runner --message=\"commit message\" --save-as-images php56"
    echo
    echo -e "  \033[1mSERVICE\033[0m"
    echo -e "      availables : \033[4mall, php*, mysql*, tomcat*, mysql56, tomcat7\033[0m"
    echo -e "      \033[4m, php53, php54, php55, php56\033[0m"
    echo -e "      It can't be started as multiple php services because of"
    echo -e "      using at 80, 443 port."
    echo
    exit 1
}
