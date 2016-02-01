#!/bin/sh

DOCKER_RUNNER_PROJECT=$(hostname -s)

[ -d /mnt/$DOCKER_RUNNER_PROJECT ] || sudo mkdir -p /mnt/$DOCKER_RUNNER_PROJECT
sudo mount -t vboxsf -o defaults,uid=1000,gid=50,dmode=755,fmode=644 "${DOCKER_RUNNER_PROJECT}" /mnt/$DOCKER_RUNNER_PROJECT

[ -d /mnt/webapps ] || sudo mkdir -p /mnt/webapps
sudo mount -t vboxsf -o defaults,uid=0,gid=0,dmode=755,fmode=644 "webapps" /mnt/webapps

[ -d /mnt/docker-entrypoint-init.d ] || sudo mkdir -p /mnt/docker-entrypoint-init.d
sudo mount -t vboxsf -o defaults,uid=0,gid=0,dmode=755,fmode=755 "docker-entrypoint-init.d" /mnt/docker-entrypoint-init.d

[ -d /mnt/build ] || sudo mkdir -p /mnt/build
sudo mount -t vboxsf -o defaults,uid=0,gid=0,dmode=755,fmode=644 "build" /mnt/build

[ -d /mnt/php ] || sudo mkdir -p /mnt/php
sudo mount -t vboxsf -o defaults,uid=48,gid=48,dmode=755,fmode=644 "php" /mnt/php

[ -d /mnt/tomcat7 ] || sudo mkdir -p /mnt/tomcat7
sudo mount -t vboxsf -o defaults,uid=91,gid=91,dmode=755,fmode=644 "tomcat7" /mnt/tomcat7

