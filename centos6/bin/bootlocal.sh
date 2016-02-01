#!/bin/sh

if [ -x /var/lib/boot2docker/docker-compose -a ! -e /usr/local/bin/docker-compose ]; then
    ln -s /var/lib/boot2docker/docker-compose /usr/local/bin/docker-compose
fi


if [ ! -x /usr/local/bin/docker-runner ]; then
    cat << EOF | sudo tee /usr/local/bin/docker-runner
#!/bin/ash

_HOST=\$(hostname)
cd /mnt/\${_HOST}
ash docker-runner.sh "\$@"

EOF
    sudo chmod 755 /usr/local/bin/docker-runner
fi
