#!/bin/bash

shopt -s dotglob

export JAVA_HOME=/usr/java/default
export CATALINA_BASE=/tomcat7
export CATALINA_HOME=/usr/local/stow/tomcat7


## tomcat conf, logs
if [[ ! -h /etc/tomcat7 ]]; then
    ln -s /tomcat7/conf /etc/tomcat7
fi
if [[ ! -h /var/log/tomcat7 ]]; then
    ln -s /tomcat7/logs /var/log/tomcat7
fi

## root
if [[ $(/bin/ls /root | wc -l) -eq 0 ]]; then
    [[ -n $(alias rm 2>/dev/null) ]] && unalias rm
    [[ -n $(alias cp 2>/dev/null) ]] && unalias cp
    [[ -n $(alias mv 2>/dev/null) ]] && unalias mv
    cp -RHPfp /docker-storage/root/* /root/ 2>/dev/null
    if [[ -d /mnt/webapps/tmp/root ]]; then
        cp -f /mnt/webapps/tmp/root/.bash_profile /root/ 2>/dev/null
        cp -f /mnt/webapps/tmp/root/.bashrc /root/ 2>/dev/null
    fi
    source /root/.bash_profile
    source /root/.bashrc
fi

## /usr/local
if [[ $(/bin/ls /usr/local | wc -l) -eq 0 ]]; then
    cp -RHPfp /docker-storage/usr/local/* /usr/local/ 2>/dev/null
fi

## jdk
if [[ $(/bin/ls /usr/java | wc -l) -eq 0 ]]; then
    cp -RHPfp /docker-storage/usr/java/* /usr/java/ 2>/dev/null
fi

## tomcat bin
if [[ -d /mnt/tomcat7/bin ]]; then
    cp -RHPfp /mnt/tomcat7/bin/* /tomcat7/bin/ 2>/dev/null
    chmod -R 755 /tomcat7/bin
fi

## tomcat lib
if [[ -d /mnt/tomcat7/lib ]]; then
    cp -RHPfp /mnt/tomcat7/lib/* /tomcat7/lib/ 2>/dev/null
fi

## root
if [[ -d /mnt/webapps/tmp/root ]]; then
    cp -RHPf /mnt/webapps/tmp/root/* /root/ 2>/dev/null
fi


/usr/local/stow/tomcat7/bin/catalina.sh run
