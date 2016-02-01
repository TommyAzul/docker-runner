#!/bin/bash

shopt -s dotglob


## php.ini, php.d
if [[ ! -h /etc/php.ini ]]; then
    ln -s /etc/php/php.ini /etc/php.ini
fi
if [[ ! -h /etc/php.d ]]; then
    ln -s /etc/php/conf.d /etc/php.d
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

## php extensions
if [[ $(/bin/ls /usr/lib64/php | wc -l) -eq 0 ]]; then
    cp -RHPfp /docker-storage/php/* /usr/lib64/php/ 2>/dev/null
    if [[ -d /mnt/webapps/php/modules ]]; then
        cp -f /mnt/webapps/php/modules/* /usr/lib64/php/modules/ 2>/dev/null
    fi
fi
if [[ -d /docker-storage/php-zts ]]; then
    if [[ $(/bin/ls /usr/lib64/php-zts | wc -l) -eq 0 ]]; then
        cp -RHPfp /docker-storage/php-zts/* /usr/lib64/php-zts/ 2>/dev/null
        if [[ -d /mnt/webapps/php/modules ]]; then
            cp -f /mnt/webapps/php/modules/* /usr/lib64/php-zts/modules/ 2>/dev/null
        fi
    fi
fi

## php pear
if [[ $(/bin/ls /usr/share/pear | wc -l) -eq 0 ]]; then
    cp -RHPfp /docker-storage/php/pear /usr/share/ 2>/dev/null
fi
if [[ -d /docker-storage/php/pear-data ]]; then
    if [[ $(/bin/ls /usr/share/pear-data | wc -l) -eq 0 ]]; then
        cp -RHPfp /docker-storage/php/pear-data /usr/share/ 2>/dev/null
    fi
fi

## nodejs (nvm, node, npm)
if [[ ! -d /root/.nvm ]]; then
    cd /root
    curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | sh
    source /root/.nvm/nvm.sh
    nvm install 4.2.6
    nvm install 0.12.9
fi
if [[ ! -d /root/.nvm/versions ]]; then
    source /root/.nvm/nvm.sh
    nvm install 4.2.6
    nvm install 0.12.9
fi

## php composer
if [[ ! -f /usr/local/bin/composer ]]; then
    if [[ ! -f /usr/local/stow/php-composer/bin/composer ]]; then
        mkdir -p /usr/local/stow/php-composer/bin 2>/dev/null
        cd /tmp
        curl -sS https://getcomposer.org/installer | php
        mv composer.phar /usr/local/stow/php-composer/bin/composer
    fi
    cd /usr/local/stow
    stow -R php-composer 2>/dev/null
fi

## php bin
if [[ -d /mnt/webapps/php/bin ]]; then
    cp -RHPf /mnt/webapps/php/bin/* /webapps/bin/ 2>/dev/null
    chmod -R 755 /webapps/bin
    chown -R 48:48 /webapps/bin
fi

## php libs
if [[ -d /mnt/webapps/php/libs ]]; then
    cp -RHPf /mnt/webapps/php/libs/* /webapps/libs/ 2>/dev/null
    chown -R 48:48 /webapps/libs
fi

## root
if [[ -d /mnt/webapps/tmp/root ]]; then
    cp -RHPf /mnt/webapps/tmp/root/* /root/ 2>/dev/null
fi


/usr/sbin/apachectl -D FOREGROUND
