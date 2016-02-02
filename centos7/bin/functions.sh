#!/bin/ash

getConfig() {
    local category=$1
    cat $CONF | \
        sed -ne "/^\[${category}\]$/,/^$/p" | \
        sed -e 1d -e '/^$/d' | \
        egrep -v '^#' | \
        sed -r "s/@@DOCKER_IMAGE_PROJECT@@/${DOCKER_IMAGE_PROJECT}/g"
}

setOptions() {
    local argv=${1%=*}
    local val=${1#*=}

    case "$argv" in
        -v|--verbose|--debug)
            OPTS=$OPTS" "$argv
            DEBUG=0
            return 0
            ;;
        -ja|--ja|--japanese)
            OPTS=$OPTS" "$argv
            LANGUAGE=ja
            return 0
            ;;
        -en|--en|--english)
            OPTS=$OPTS" "$argv
            LANGUAGE=en
            return 0
            ;;
        --lang|--language)
            OPTS=$OPTS" "$argv
            [ "$val" = "en" -o "$val" = "english" ]  && LANGUAGE=en
            [ "$val" = "ja" -o "$val" = "japanese" ] && LANGUAGE=ja
            retrun 0
            ;;
        --msg|--message)
            OPTS=$OPTS" "$argv
            COMMIT_MESSAGE="$val"
            return 0
            ;;
    esac
    return 1
}

setServices() {
    for argv in "$@"; do
        setOptions "$argv"
        [ $? -eq 1 ] && ARGS=$ARGS" "$argv
        [ "$(echo $argv | tr "[:upper:]" "[:lower:]")" = "all" ] && ARGS=all
    done

    if [ "$ARGS" = "all" ]; then
        ARGS=$(getConfig "services" | awk '{print $2}' | uniq)
    fi
}

setArguments() {
    if [ $# -gt 0 ]; then
        for argv in "$@"; do
            setOptions "$argv"
            [ $? -eq 1 ] || shift
        done
        CMD=$1
        shift
        setServices "$@"
    fi
}

setImages() {
    local opt=$1
    shift
    local service="$@"

    [ -z "$service" ] && return 1

    if [ "$opt" = "dep" ]; then
        local service=$(getConfig "dependent services" | egrep "$(echo $service | sed 's/ /|/g')" | awk '{print $2}' | uniq)" "$service
    fi

    SERVICE_IMAGES=$(getConfig "services" | egrep "$(echo $service | sed 's/ /|/g')" | awk '{print $1}' | uniq)
    STORAGE_IMAGES=$(getConfig "storages" | egrep "$(echo $service | sed 's/ /|/g')" | awk '{print $1}' | uniq)

    if [ -n "$DEBUG" ]; then
        echo
        echo "SERVICE IMAGES : "$SERVICE_IMAGES
        echo "STORAGE IMAGES : "$STORAGE_IMAGES
    fi
}

setContainers() {
    local opt=$1
    shift
    local service="$@"
    local priority_keys=$(getConfig priority)
    local priorities=

    [ -z "$service" ] && return 1

    ## sort services by priority
    for k in $priority_keys; do
        local priorities=$priorities" "$(echo $service | sed 's/ /\n/g' | grep "$k")
    done

    local priorities=$priorities" "$(echo $service | sed 's/ /\n/g' | egrep -v "$(echo $priority_keys | sed 's/ /|/g')")
    local service=$priorities

    ## add dependent service
    if [ "$opt" = "dep" ]; then
        local dependent_services=
        local dependent_services_all=$(getConfig "dependent services" | egrep "$(echo $service | sed 's/ /|/g')" | awk '{print $2}' | uniq)

        for d in $dependent_services_all; do
            if [ -z "$(echo $priorities | sed 's/ /\n/g' | grep "$d")" ]; then
                local dependent_services=$dependent_services" "$d
            fi
        done

        local service=$dependent_services" "$priorities
    fi

    SERVICE_CONTAINERS=$(getConfig "services" | egrep "$(echo $service | sed 's/ /|/g')" | awk '{print $2}' | uniq)
    STORAGE_CONTAINERS=$(getConfig "storages" | egrep "$(echo $service | sed 's/ /|/g')" | awk '{print $2}' | uniq)

    if [ -n "$DEBUG" ]; then
        echo "SERVICE CONTAINERS : "$SERVICE_CONTAINERS
        echo "STORAGE CONTAINERS : "$STORAGE_CONTAINERS
        echo
    fi
}

setConfigs() {
    STORAGE_IMAGES=
    SERVICE_IMAGES=
    STORAGE_CONTAINERS=
    SERVICE_CONTAINERS=

    setImages "$@"
    setContainers "$@"
}

resetConfigs() {
    STORAGE_IMAGES=
    SERVICE_IMAGES=
    STORAGE_CONTAINERS=
    SERVICE_CONTAINERS=
}

getStorageImages() {
    echo $STORAGE_IMAGES
}

getServiceImages() {
    echo $SERVICE_IMAGES
}

getStorageContainers() {
    echo $STORAGE_CONTAINERS
}

getServiceContainers() {
    echo $SERVICE_CONTAINERS
}

checkImages() {
    local error=0

    if [ -z "$(docker images -q $BASE_IMAGE)" ]; then
        BUILD_STORAGE_IMAGES=$BUILD_STORAGE_IMAGES" $BASE_IMAGE"
        local error=1
    fi

    case "$1" in
        storages)
            for img in $(getStorageImages); do
                if [ -z "$(docker images -q $img)" ]; then
                    BUILD_STORAGE_IMAGES=$BUILD_STORAGE_IMAGES" "$img
                    local error=1
                fi
            done
            ;;
        services)
            for img in $(getServiceImages); do
                if [ -z "$(docker images -q $img)" ]; then
                    BUILD_SERVICE_IMAGES=$BUILD_SERVICE_IMAGES" "$img
                    local error=1
                fi
            done
            ;;
    esac

    return $error
}

checkContainers() {
    local error=0

    case "$1" in
        storages)
            for srv in $(getStorageContainers); do
                if [ -z "$(docker ps -a | grep $srv 2>/dev/null)" ]; then
                    START_STORAGE_CONTAINERS=$START_STORAGE_CONTAINERS" "$srv
                    local error=1
                fi
            done
            ;;
        services)
            for srv in $(getServiceContainers); do
                if [ -z "$(docker ps | grep $srv 2>/dev/null)" ]; then
                    START_SERVICE_CONTAINERS=$START_SERVICE_CONTAINERS" "$srv
                    local error=1
                fi
            done
            ;;
    esac

    return $error
}

buildImages() {
    case "$1" in
        storages)
            shift
            local args="$@"
            cd $BUILD_DIR
            for img in $args; do
                if [ "$img" = "$BASE_IMAGE" ]; then
                    local dockerfile=$BASE_DOCKERFILE
                else
                    local dockerfile=$(getConfig storages | grep $img | awk '{print $3}' | uniq)
                fi
                [ -n "$DEBUG" ] && echo "docker build -f $dockerfile -t $img ."
                docker build -f $dockerfile -t $img .
            done
            cd -
            ;;
        services)
            shift
            local args="$@"
            cd $BUILD_DIR
            for img in $args; do
                local composefile=$(getConfig services | grep $img | awk '{print $3}' | uniq)
                local service=$(getConfig services | grep $img | awk '{print $2}' | uniq)

                [ -n "$DEBUG" ] && echo "docker-compose -p $PROJ -f $composefile build $service"
                docker-compose -p $PROJ -f $composefile build $service
            done
            cd -
            ;;
    esac
}

startServices() {
    case "$1" in
        storages)
            shift
            local args="$@"
            cd $BUILD_DIR
            for srv in $args; do
                local image=$(getConfig storages | grep $srv | awk '{print $1}' | uniq)
                [ -n "$DEBUG" ] && echo "docker create -it --name $srv $image"
                docker create -it --name $srv $image
            done
            cd -
            ;;
        services)
            shift
            local args="$@"
            cd $BUILD_DIR
            for srv in $args; do
                local composefile=$(getConfig services | grep $srv | awk '{print $3}' | uniq)
                local prohibit=$(getConfig prohibit)
                local running=$(docker ps | egrep "$(echo $prohibit | sed -r 's/ /|/g')" | awk '{print $NF}' | xargs echo)

                if [ -n "$running" ]; then
                    [ -n "$DEBUG" ] && echo "docker stop $running"
                    docker stop $running

                    [ -n "$DEBUG" ] && echo "docker-compose -p $PROJ -f $composefile up -d $srv"
                    docker-compose -p $PROJ -f $composefile up -d $srv
                else
                    [ -n "$DEBUG" ] && echo "docker-compose -p $PROJ -f $composefile up -d $srv"
                    docker-compose -p $PROJ -f $composefile up -d $srv
                fi
            done
            cd -
            ;;
    esac
}

build() {
    if [ -z "$(which docker-compose)" ]; then
        echo
        echo "First, you need setup. It can't find docker-compose."
        echo "ash $0 setup"
        echo
        exit 100
    fi

    checkImages storages
    if [ $? -ne 0 ] ; then
        [ -n "$DEBUG" ] && echo && echo "BUILD STORAGE IMAGES : "$BUILD_STORAGE_IMAGES
        buildImages storages $BUILD_STORAGE_IMAGES
    fi

    checkContainers storages
    if [ $? -ne 0 ] ; then
        [ -n "$DEBUG" ] && echo && echo "START STORAGE CONTAINERS : "$START_STORAGE_CONTAINERS
        startServices storages $START_STORAGE_CONTAINERS
    fi

    checkImages services
    if [ $? -ne 0 ] ; then
        [ -n "$DEBUG" ] && echo && echo "BUILD SERVICE IMAGES : "$BUILD_SERVICE_IMAGES
        buildImages services $BUILD_SERVICE_IMAGES
    fi
}

start () {
    if [ -z "$(which docker-compose)" ]; then
        echo
        echo "First, you need setup. It can't find docker-compose."
        echo "ash $0 setup"
        echo
        exit 100
    fi

    checkContainers storages
    if [ $? -ne 0 ] ; then
        [ -n "$DEBUG" ] && echo && echo "START STORAGE CONTAINERS : "$START_STORAGE_CONTAINERS
        startServices storages $START_STORAGE_CONTAINERS
    fi

    checkContainers services
    if [ $? -ne 0 ] ; then
        [ -n "$DEBUG" ] && echo && echo "START SERVICE CONTAINERS : "$START_SERVICE_CONTAINERS
        startServices services $START_SERVICE_CONTAINERS
    fi
}

login() {
    if [ -n "$(echo "$@" | egrep "data|db")" ]; then
        local shell=/bin/sh
        local service=$(getStorageContainers | awk '{print $NF}')
    else
        local shell=/bin/bash
        local service=$(getServiceContainers | awk '{print $NF}')
    fi

    if [ -n "$service" -a -n "$(docker ps | egrep "$service")" ]; then
        local service=$(docker ps | egrep "$service" | awk '{print $NF}')

        [ -n "$DEBUG" ] && echo "docker exec -it $service $shell"
        docker exec -it $service $shell
    else
        local availables=$(docker ps | awk '{print $NF}' | grep -v "NAMES")

        echo
        [ -n "$service" ] && docker exec -it $service $shell || echo "AVAILABLE SERVICE : "$availables
        echo
        docker ps -a
        echo
    fi
}

stop() {
    case "$1" in
        storages)
            local service=$(getStorageContainers)
            ;;
        services)
            local service=$(getServiceContainers)
            ;;
        *)
            local service=$(getServiceContainers)
            ;;
    esac

    for srv in $service; do
        if [ -n "$(docker ps -a | grep $srv)" ]; then
            [ -n "$DEBUG" ] && echo docker stop $srv
            [ -n "$DEBUG" ] && echo docker rm -v $srv
            docker stop $srv
            docker rm -v $srv
        fi
    done
}

deleteImages() {
    local images=$(getStorageImages)" "$(getServiceImages)
    local base=$(echo $BASE_IMAGE | cut -d: -f1)

    if [ $# -gt 0 ]; then
        if [ -n "$(echo "$@" | grep $base)" ]; then
            local images=$images" "$base
        fi
    fi

    for img in $images; do
        if [ -n "$(docker images | grep $img)" ]; then
            [ "$img" = "$base" ] && local img=$BASE_IMAGE
            [ -n "$DEBUG" ] && echo "docker rmi $img"
            docker rmi $img
        fi
    done
}

statusImages() {
    local _image=$(getStorageImages)" "$(getServiceImages)
    local image=

    for img in $_image; do
        if [ -n "$(docker images | grep $img)" ]; then
            local image=$image" "$img
        fi
    done

    if [ -n "$image" ]; then
        echo
        [ -n "$DEBUG" ] && echo "docker images | egrep \"$(echo $image | sed 's/ /|/g')\"" && echo
        docker images | sed -ne 1p
        docker images | egrep "$(echo $image | sed 's/ /|/g')"
    else
        echo
        [ -n "$DEBUG" ] && echo "docker images" && echo
        docker images
    fi
}

statusPs() {
    local _service=$(getStorageContainers)" "$(getServiceContainers)
    local service=

    for srv in $_service; do
        if [ -n "$(docker ps -a | grep $srv)" ]; then
            local service=$service" "$srv
        fi
    done

    if [ -n "$service" ]; then
        echo
        [ -n "$DEBUG" ] && echo "docker ps -a | egrep \"$(echo $service | sed 's/ /|/g')\"" && echo
        docker ps -a | sed -ne 1p
        docker ps -a | egrep "$(echo $service | sed 's/ /|/g')"
    else
        echo
        [ -n "$DEBUG" ] && echo "docker ps -a" && echo
        docker ps -a
    fi
}

statusStats() {
    local _service=$(getStorageContainers)" "$(getServiceContainers)
    local service=

    for srv in $_service; do
        if [ -n "$(docker ps -a | grep $srv)" ]; then
            local service=$service" "$srv
        fi
    done

    if [ -n "$service" ]; then
        echo
        [ -n "$DEBUG" ] && echo docker stats --no-stream $service && echo
        docker stats --no-stream $service
    fi
}

status() {
    case "$1" in
        images)
            statusImages
            echo
            ;;
        ps)
            statusPs
            echo
            ;;
        stats)
            statusStats
            echo
            ;;
        *)
            statusImages
            statusPs
            statusStats
            echo
            ;;
    esac
}

backupData() {
    local _storage=$(getStorageContainers)
    local storage=

    [ -d $BACKUP_DIR ] || sudo mkdir -p $BACKUP_DIR
    [ -d $DIR/backup/ ] || mkdir -p $DIR/backup/
    cd $BACKUP_DIR

    for s in $_storage; do
        [ -n "$(docker ps -a | grep $s)" ] && local storage=$s
        local date=$DATETIME

        if [ -n "$storage" ]; then
            BACKUP_TMP_DIR=_${storage}.$DATETIME
            BACKUP_ARCHIVE=backup_${storage}.${date}
            BACKUP_STRUCTURE=$BACKUP_TMP_DIR/.structure-file.txt

            sudo mkdir -p $BACKUP_TMP_DIR
            [ -n "$DEBUG" ] && echo "docker inspect --format='{{range .Mounts}}{{print .Destination}}{{print \",\"}}{{println .Source}}{{end}}' $storage | sudo tee $BACKUP_STRUCTURE 1>/dev/null"

            docker inspect --format='{{range .Mounts}}{{print .Destination}}{{print ","}}{{println .Source}}{{end}}' $storage | sudo tee $BACKUP_STRUCTURE 1>/dev/null

            cat $BACKUP_STRUCTURE | while read d; do
                if [ -n "$d" ]; then
                    local _dst=$(echo $d | cut -d, -f1)
                    local dst=${_dst#/}
                    local src=$(echo $d | cut -d, -f2)

                    [ -n "$DEBUG" ] && echo "sudo mkdir -p $BACKUP_TMP_DIR/$dst"
                    [ -n "$DEBUG" ] && echo "sudo cp -RHPfp $src $BACKUP_TMP_DIR/$dst/" && echo
                    sudo mkdir -p $BACKUP_TMP_DIR/$dst
                    sudo cp -RHPfp $src $BACKUP_TMP_DIR/$dst/
                fi
            done

            [ -n "$DEBUG" ] && echo && echo "sudo tar zcf $BACKUP_ARCHIVE.tar.gz $BACKUP_TMP_DIR"
            [ -n "$DEBUG" ] && echo "sudo rm -rf $BACKUP_TMP_DIR" && echo
            sudo tar zcf $BACKUP_ARCHIVE.tar.gz $BACKUP_TMP_DIR
            sudo rm -rf $BACKUP_TMP_DIR
            sudo mv $BACKUP_ARCHIVE.tar.gz $DIR/backup/
        fi
    done
    cd -
}

restoreData() {
    local storage=$(getStorageContainers | awk '{print $NF}')
    local argdate=
    [ -n "$2" ] && local argdate=$(echo $2 | sed -r 's/ //g')

    [ -d $BACKUP_DIR ] || sudo mkdir -p $BACKUP_DIR
    cd $BACKUP_DIR

    if [ -n "$(docker ps -a | grep $storage)" ]; then
        if [ -n "$argdate" ]; then
            local file=$(/bin/ls $DIR/backup/backup_${storage}.${argdate}.tar.gz 2>/dev/null | sort | tail -1)
        else
            local file=$(/bin/ls $DIR/backup/backup_${storage}.*.*.tar.gz 2>/dev/null | sort | tail -1)
        fi

        if [ -n "$file" ]; then
            local dir=$(echo $file | sed -r 's/^.+\/backup(_.+\.[0-9]+\.[0-9]+)\.tar\.gz/\1/g')

            [ -n "$DEBUG" ] && echo "tar zxf $file"
            sudo tar zxf $file

            cat $dir/.structure-file.txt | while read d; do
                if [ -n "$d" ]; then
                    local _from=$(echo $d | cut -d, -f1)
                    local from=${_from#/}
                    local to=$(docker inspect --format='{{range .Mounts}}{{if eq .Destination "'$_from'"}}{{print .Source}}{{end}}{{end}}' $storage | sed -r 's/\/_data//g')

                    if [ -d $dir/$from/_data -a -n "$to" ]; then
                        [ -n "$DEBUG" ] && echo "sudo cp -RHPfp $dir/$from/_data $to/"
                        sudo cp -RHPfp $dir/$from/_data $to/
                    fi
                fi
            done

            [ -n "$DEBUG" ] && echo "sudo rm -rf $dir"
            sudo rm -rf $dir
        fi
    fi
    cd -
}

saveAsImages() {
    local service=$(getServiceContainers)

    for srv in $service; do
        if [ -n "$(docker ps | grep $srv)" ]; then
            local img=$(getConfig "services" | grep $srv | awk '{print $1}')
            [ -z "$COMMIT_MESSAGE" ] && COMMIT_MESSAGE="commited at $DATETIME_FM"

            [ -n "$DEBUG" ] && echo "docker commit -m \"$COMMIT_MESSAGE\" $srv $img"
            docker commit -m "$COMMIT_MESSAGE" $srv $img
        fi
    done
}
