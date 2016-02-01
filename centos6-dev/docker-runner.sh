#!/bin/ash

[ -n "$DEBUG" ] || DEBUG=
[ -n "$LANGUAGE" ] || LANGUAGE=en

DIR=$(pwd)
BUILD_DIR=$DIR/build
BIN_DIR=$DIR/bin
BACKUP_DIR=/root/backup
TMP=/tmp

PROJ=$(basename $DIR)
CONF=$BIN_DIR/docker-runner.conf

## local time (GMT=0 means same with UTC, GMT=9 means Japanese local time)
[ -n "$GMT" ] || GMT=9

DATE=$(date -d "@$(( $(date -u +%s) + $(($GMT * 3600)) ))" +"%Y%m%d")
DATETIME=$(date -d "@$(( $(date -u +%s) + $(($GMT * 3600)) ))" +"%Y%m%d.%H%M%S")
TIME=$(date -d "@$(( $(date -u +%s) + $(($GMT * 3600)) ))" +"%H%M%S")

DATE_FM=$(date -d "@$(( $(date -u +%s) + $(($GMT * 3600)) ))" +"%Y/%m/%d")
DATETIME_FM=$(date -d "@$(( $(date -u +%s) + $(($GMT * 3600)) ))" +"%Y/%m/%d %H:%M:%S")
TIME_FM=$(date -d "@$(( $(date -u +%s) + $(($GMT * 3600)) ))" +"%H:%M:%S")

[ -n "$(echo $PROJ | awk '/dev/ {print}')" ] && REL_IMAGE= || REL_IMAGE=-prod
[ -n "$(echo $PROJ | awk '/dev/ {print}')" ] && REL_DOCKERFILE=dev || REL_DOCKERFILE=prod
BASE_IMAGE=${PROJ}${REL_IMAGE}:latest
BASE_DOCKERFILE=Dockerfile-$REL_DOCKERFILE

BUILD_STORAGE_IMAGES=
BUILD_SERVICE_IMAGES=
START_STORAGE_CONTAINERS=
START_SERVICE_CONTAINERS=

CMD=
OPTS=
ARGS=

source $BIN_DIR/functions.sh
setArguments "$@"

if [ -n "$DEBUG" ]; then
    echo "CMD  : "$CMD
    echo "OPTS : "$OPTS
    echo "ARGS : "$ARGS
fi

case "$CMD" in
    --build|build)
        setConfigs dep $ARGS
        build
        status images
        ;;
    --start|start)
        setConfigs dep $ARGS
        build
        start
        status
        ;;
    --login|login)
        setConfigs nodep $ARGS
        login $ARGS
        ;;
    --stop|stop)
        setConfigs nodep $ARGS
        stop services
        resetConfigs
        status
        ;;
    --status|status)
        setConfigs dep $ARGS
        status
        ;;
    --restart|restart)
        setConfigs nodep $ARGS
        stop services
        setConfigs dep $ARGS
        build
        start
        status
        ;;
    --refresh|refresh)
        setConfigs nodep $ARGS
        stop services
        stop storages
        setConfigs dep $ARGS
        build
        start
        status
        ;;
    --rebuild|rebuild)
        setConfigs nodep $ARGS
        stop services
        stop storages
        deleteImages
        setConfigs dep $ARGS
        build
        status images
        ;;
    --delete-storages)
        setConfigs nodep $ARGS
        stop services
        stop storages
        resetConfigs
        status
        ;;
    --delete-images)
        setConfigs nodep $ARGS
        stop services
        stop storages
        deleteImages $ARGS
        resetConfigs
        status
        ;;
    --backup-storages)
        setConfigs nodep $ARGS
        backupData
        ;;
    --restore-storages)
        setConfigs nodep $ARGS
        restoreData $ARGS
        ;;
    --save-as-images)
        setConfigs nodep $ARGS
        saveAsImages
        stop services
        setConfigs dep $ARGS
        build
        start
        status
        ;;
    --setup|setup)
        source $BIN_DIR/setup.sh
        setup
        ;;
    --help|help)
        source $BIN_DIR/helps.${LANGUAGE}.sh
        usage
        exit 1
        ;;
    *)
        echo "Usage: $0 {build|start|stop|status|restart|refresh|rebuild|help} service"
        exit 2
esac
