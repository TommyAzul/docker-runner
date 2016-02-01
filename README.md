# docker-centos

docker service installation for Windows 7+ with docker-runner batch.


#### Which daemon and applications?

* Apache-2.2
* MySQL-5.6
* PHP-5.3 (only for centos6)
* PHP-5.4
* PHP-5.6
* Tomcat-7
* JDK-8u65 (Oracle)
* node.js-0.12.9 (installed from nvm)
* php composer

#### About docker version

* [docker-toolbox-1.9.1](https://www.docker.com/toolbox)
  * docker
  * docker-machine
* [Oracle Virtualbox-5.0.10](https://www.virtualbox.org/)
* [docker-compose-1.5.2](https://docs.docker.com/compose/install/)

As you see, Windows docker-comppose isn't supported Linux permission yet, so install in docker Tiny Linux.




## Installation

#### Docker Virtual Machine

First, you need install [docker-toolbox](https://www.docker.com/toolbox) and make sure install `Windows Git` and `Oracle Virtualbox`. If you already have Git and Virtualbox in the machine, you can install docker-toolbox without them.

It is %HOMEPATH% in the default virtual machine installation. I install at different path as the below.

Now, open cmd command line and type these. Register these env at your system too. Access ip address from host computer depends on DHCP setting of Host Only Adaptor in Virtualbox.  Usually, fourth byte ip address will be 100, and if you set `192.168.100.1` for example, access ip address will be `192.168.100.100`. You can check this access ip address with `docker-runner.bat status` command after all.

```bat
set MACHINE_STORAGE_PATH=D:\VM\Docker\machine
set DOCKER_RUNNER_PATH=D:\VM\Docker
set DOCKER_RUNNER_WEBAPPS_PATH=D:\VM\webapps

cd /d %DOCKER_RUNNER_PATH%\centos6
docker-runner.bat create

REM with ip address
docker-runner.bat --net=192.168.100.1 create

REM show help
docker-runner.bat help

REM show Japanese help
docker-runner.bat --ja help
docker-runner.bat --lang=ja help

REM checking
docker-runner.bat status
```


Help messages language depends on code page in Windows cmd. It is also same with `docker-runner` command help in virtual machine. Available language is only English and Japanese.

You are gonna create docker images after finishing to create virtual machine. When you login to virtual machine, it will setup automatically for `docker-runner` command at the same time.

```bat
docker-runner.bat login
```



#### Docker Image

Available images for docker are `php53, php54, php55, php56, mysql56, tomcat7` for now. It will be better not to build all of them, because it must take lots of time. It should be better to build partial only necessary images. Minimum preparation is done.

It is not possible to start multiple php services because of using 80, 443 port. When you start with `docker-runner start all` or `docker-runner start php*`, only php56 is start after all.

```bash
docker-runner start all

# this is same
docker-runner build all
docker-runner start all

# login
docker-runner login php56

# show help
docker-runner help

# show Japanese help
docker-runner --ja help
docker-runner --lang=ja help

# checking
curl -L http://default.dev
curl -L http://$(docker inspect --format='{{.NetworkSettings.Networks.bridge.IPAddress}}' php56)
```


To build partial images, follow the below. When you build php, mysql service is builded at the same time automatically.

```bash
docker-runner start php54 php56

# or

docker-runner start php*
```



#### Server Environment

There are config files for each servers at `%DOCKER_RUNNER_PATH%\centos6\build\configs`, and web application path is at `%DOCKER_RUNNER_WEBAPPS_PATH%\php, %DOCKER_RUNNER_WEBAPPS_PATH%\tomcat7`. These files at the path are realtime sharing using with VirtualBox share function.

Mount infomations of config files:

```
# HOST <-> SERVICE
build\configs\apache22\conf   <-> /etc/httpd/conf
build\configs\apache22\conf.d <-> /etc/httpd/conf.d
build\configs\mysql56         <-> /etc/mysql
build\configs\mysql56         <-> /etc/mysql
build\configs\php各バージョン   <-> /etc/php
build\configs\tomcat7         <-> /tomcat7/conf

# symbolic link
/etc/php/php.ini -> /etc/php.ini
/etc/php/conf.d  -> /etc/php.d

# tomcat environment
JAVA_HOME=/usr/java/default
CATALINA_BASE=/tomcat7
CATALINA_HOME=/usr/local/stow/tomcat7
```


Mount infomations of server startup scripts:

```
# HOST <-> SERVICE
build\docker-entrypoint-init.d <-> /docker-entrypoint-init.d
```


Mount infomations of web application:

```
# HOST <-> SERVICE
webapps\php\apps        <-> /webapps/apps
webapps\tomcat7\webapps <-> /tomcat7/webapps
```


Web application and MySQL database settings:

```
# php
/webapps/apps
/webapps/libs (user library, copy files at startup)

# php pear
/usr/share/pear

# php shared libraries
/usr/lib64/php/modules

# mysql
/var/lib/mysql

# jdk
/usr/java

# tomcat
/usr/local/stow/tomcat7

# tomcat web root for user
/tomcat7
/tomcat7/webapps
```





## The other options for docker-runner.bat in Windows

#### How to create another docker machines

```dos.bat
docker-runner.bat -p centos7 create

REM or

cd /d %DOCKER_RUNNER_PATH%\centos7
docker-runner.bat create

REM with ip address
docker-runner.bat --net=192.168.110.1 create
```



#### How to set machine specs

```dos.bat
docker-runner.bat --cpu=4 --mem=4096 create

REM default parameter
docker-runner.bat --cpu=2 --mem=2048 create
```



#### Etc.

```dos.bat
REM stop virtual machine
docker-runner.bat stop

REM restart virtual machine
docker-runner.bat restart
```





## The other options for docker-runner in Docker machine

#### How to switch running service

```bash
# php5.5
docker-runner start php55

# this is same
docker-runner stop php56
docker-runner start php55

# login
docker-runner login php55
```


#### How to show service status

```bash
docker-runner status

# show including service performance
docker-runner status all

# show all related php* (mysql too)
docker-runner status php*
```


#### How to restart service

When you change server settings, you should restart service.

```bash
docker-runner restart php56

# multiple services
docker-runner restart php56 mysql56
```


If you restart servies, it will be gone the modifications that you add binary packages or change server settings except apache, php, mysql, tomcat. When you need save them, you can run with --save-as-images option.


#### How to save modifications into docker image

Services exist in docker container at running, but when you restart service, it will startup from docker image. For this, even if you change something at running service, once restart service, then the modifications are gone.

```bash
docker-runner --save-as-images php56

# add modification contents
docker-runner --message="modification contents" --save-as-images php56

# show history
docker history centos6_php56
```



#### How to initialize

You can initialize service except supported web server configs and web applications.

```bash
docker-runner refresh php56
docker-runner refresh mysql56

# multiple services
docker-runner refresh php56 mysql56

# all php versions
docker-runner refresh php*
```


#### How to backup storage data

You should backup storage data regularly which contains mysql database data, php pear and php shared modules. When you need check backup locations, you can run with debug option.

```bash
docker-runner --backup-storages php56 mysql56

# debug
docker-runner -v --backup-storages php56 mysql56

# all services
docker-runner --backup-storages all
```


#### How to restore data

You can restore data from backup file into current storage. This command is not allowed to set multiple services.

If you change volums in storage, it will try to restore data only exsist directories in backup, and the others will be ignored.

```bash
docker-runner --restore-storages php56

# show commands of restore
docker-runner -v --restore-storages php56

# select specific backup
docker-runner --restore-storages php56 20160101.101024
```



#### How to rebuild docker image

Rebuild option rebuild service image including storage. If you want to keep the data like mysql database, etc., you need backup first, and restore data after rebuild images. When you save container service as in image, this image will be destroied. You need keep this modification, then need to customize build file. Build files are at `build\Dockerfile-*`.

```bash
docker-runner rebuild php56

# multiple services
docker-runner rebuild php56 mysql56

# example of mysql database backup, rebuild and restore
docker-runner --backup-storages mysql56
docker-runner rebuild mysql56
docker-runner --restore-storages mysql56
```





## How to start docker container after setup docker and startup windows.

Open cmd command line as Administrator.

```dos.bat
set MACHINE_STORAGE_PATH=D:\VM\centos\machine
docker-machine start centos6
docker-machine env centos6 --shell cmd

## copy and paste env

docker-machine ssh centos6
```

In the Tiny Linux command prompt.

```bash
cd /mnt/centos6
docker-compose up -d
docker ps -a
```

If you need login to docker container,

```bash
docker exec -it php56 bash
# Or
docker exec -it mysql56 bash
```




## docker, docker-compose commands help


#### check container

```bash
docker-compose ps
docker ps
docker ps -a
```


#### check logs

```bash
docker-compose logs
docker-compose logs ContainerId,,,
docker logs ContainerId,,,
```


#### check build history

```bash
docker-compose history Repository:Tag
```


#### stop container

```bash
docker-compose stop
docker-compose stop ContainerId,,,
docker stop ContainerId,,,
```


#### delete container

```bash
docker-compose rm
docker-compose rm ContainerId,,,
docker rm ContainerId,,,
```


#### create and start container

```bash
cd BuildDir(the path placed docker-compose.yml)
docker-compose up -d
docker-compose -p ProjectName up -d
docker-compose -p ProjectName up -d ContainerName
docker-compose -p ProjectName -f DockerComposeYamlfileName up -d
```


#### login to container

```bash
docker exec -it ContainerName bash
docker attach ContainerName
```


#### rebuild container when you change docker-compose.yml

```bash
docker-compose build --no-cache
docker-compose -p ProjectName build ServiceName
docker-compose -p ProjectName -f docker-compose-file-name.yml build ServiceName --no-cache
docker build -t Repository:Tag .
```


#### custom docker image

```bash
docker pull centos:6

cd /mnt/centos6
docker build -t centos6/dev:1.0 .
docker images

docker run -d -it -p LocalPort:ExternalPort --hostname HostName --name ContainerName centos:6 /bin/bash
docker run -d -it --name ContainerName centos:6 /bin/bash
```


#### start container from image

```bash
docker run -d -it -p 80:80 -p 443:443 --name php dev:1.0
docker run -d -it --hostname dev.localhost -p 80:80 -p 443:443 -v /path/to/host:/path/to/container --name php54 dev:php54
docker ps -a
```


#### create custom image from container

```bash
docker commit -m "test1" ContainerId contos6/dev:1.0
```


#### import, export docker

Nolonger available to startup with "docker-compose up -d" if it's exported from container into a file.

```bash
docker export ContainerId > /path/to/host/ExportFileName.tar
cat /path/to/host/exportFileName.tar | docker import - DockerImageName(Repository:Tag, ie centos6_php54:latest)
```

If you need use docker-compose, it's better to export from "docker save DOCKER_IMAGE".

```bash
docker save Repository:Tag > /path/to/host/ExportFileName.tar
cat /path/to/host/exportFileName.tar | docker import - DockerImageName(Repository:Tag, ie centos6_php54:latest)
```

