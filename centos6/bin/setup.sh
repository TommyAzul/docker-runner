#!/bin/ash

BOOT2DOCKER_DIR=/var/lib/boot2docker
INIT=bootlocal.sh
SYNC=bootsync.sh
COMPOSE=docker-compose


getLatestComposeVersion() {
    curl -sL "https://github.com/docker/compose/releases" | \
        sed -rn '/<h1 class="release-title">/,/<\/h1>/p' | \
        egrep -v 'h1|RC' | \
        head -1 | \
        sed -r 's/\s*<a href=".+\/([rc0-9\.\-]+)">.+<\/a>/\1/g'
}

getCurrentComposeVersion() {
    if [ -n "$(which docker-compose)" ]; then
        docker-compose --version | cut -d" " -f3 | sed -r 's/\,|\.//g' | sed -r 's/rc([0-9]+)/.\1/g'
    fi
}

checkComposeVersion() {
    local latest_ver=$(echo $COMPOSE_VER | sed -r 's/\,|\.//g' | sed -r 's/\-rc([0-9]+)/.\1/g')
    local current_ver=$(getCurrentComposeVersion)

    local latest_rc=0
    local current_rc=0

    if [ -n "$(echo $current_ver | egrep "\.")" ]; then
        local current_rc=$(echo $current_ver | sed -r 's/^[0-9]+\.([0-9]+)/\1/g')
        local current_ver=$(echo $current_ver | sed -r 's/^([0-9]+)\.[0-9]+/\1/g')
    fi
    if [ -n "$(echo $latest_ver | egrep "\.")" ]; then
        local latest_rc=$(echo $latest_ver | sed -r 's/^[0-9]+\.([0-9]+)/\1/g')
        local latest_ver=$(echo $latest_ver | sed -r 's/^([0-9]+)\.[0-9]+/\1/g')
    fi

    if [ -n "$DEBUG" ]; then
        echo "CURRENT VER : "$current_ver"."$current_rc
        echo "LATEST_VER  : "$latest_ver"."$latest_rc
    fi

    ## 0: download, 1: not download
    if [ $current_ver -eq $latest_ver ]; then
        if [ $current_rc -lt $latest_rc ]; then
            return 0
        else
            return 1
        fi
    elif [ $current_ver -lt $latest_ver ]; then
        return 0
    else
        return 1
    fi
}

setup() {
    COMPOSE_VER=$(getLatestComposeVersion)
    COMPOSE_URL="https://github.com/docker/compose/releases/download/${COMPOSE_VER}/${COMPOSE}-$(uname -s)-$(uname -m)"

    ## set bootlocal.sh (replace always)
    [ -n "$DEBUG" ] && echo "sudo cp -f $BIN_DIR/$INIT $BOOT2DOCKER_DIR/$INIT"
    sudo cp -f $BIN_DIR/$INIT $BOOT2DOCKER_DIR/$INIT
    sudo chmod 755 $BOOT2DOCKER_DIR/$INIT

    ## mount, set bootsync.sh (replace always)
    [ -n "$DEBUG" ] && echo "sudo cp -f $BIN_DIR/$SYNC $BOOT2DOCKER_DIR/$SYNC"
    sudo cp -f $BIN_DIR/$SYNC $BOOT2DOCKER_DIR/$SYNC
    sudo chmod 755 $BOOT2DOCKER_DIR/$SYNC

    [ -n "$DEBUG" ] && echo "sudo $BOOT2DOCKER_DIR/$SYNC"
    sudo $BOOT2DOCKER_DIR/$SYNC

    checkComposeVersion
    local chk=$?

    ## download and set docker-compose
    if [ ! -h /usr/local/bin/$COMPOSE -a ! -f $BOOT2DOCKER_DIR/$COMPOSE -o $chk -eq 0 ]; then
        [ -n "$DEBUG" ] && echo "sudo curl -L $COMPOSE_URL -o $BOOT2DOCKER_DIR/$COMPOSE"
        sudo curl -L $COMPOSE_URL -o $BOOT2DOCKER_DIR/$COMPOSE
        sudo chmod 755 $BOOT2DOCKER_DIR/$COMPOSE
    fi

    ## install docker-runner, create docker-compose link
    [ -n "$DEBUG" ] && echo "sudo $BOOT2DOCKER_DIR/$INIT"
    sudo $BOOT2DOCKER_DIR/$INIT
}
