# docker-centos

Windows7以降の環境におけるDocker構築手順


#### この設定でサポートするサーバー・アプリケーション

* Apache-2.2
* MySQL-5.6
* PHP-5.3 (centos6のみ)
* PHP-5.4
* PHP-5.6
* Tomcat-7
* JDK-8u65 (Oracle)
* node.js-0.12.9 (nvmインストール)
* php composer

#### Dockerのバージョンについて

* [docker-toolbox-1.9.1](https://www.docker.com/toolbox)
  * docker
  * docker-machine
* [Oracle Virtualbox-5.0.10](https://www.virtualbox.org/)
* [docker-compose-1.5.2](https://docs.docker.com/compose/install/)

Windows版のdocker-compposeはパーミッションの問題をクリアできないので、Tiny Linuxへインストールします。docker-compposeはバッチで常に最新のリリースバージョンへと更新されます。




## インストール

#### Docker仮想マシン作成

まず初めに、[docker-toolbox](https://www.docker.com/toolbox)をインストールします。必ず`Windows Git`、`Oracle Virtualbox`もインストールしてください。既にインストール済みの場合はdocker-toolboxインストール時にインストールオプションを外しておくことで既存のGit、Virtualboxをそのまま使用できます。

初期設定では仮想マシンが`%HOMEPATH%`（C:\Users\ログインユーザー名\）にインストールされるので、仮想マシンの構築場所を変更します。

Windows CMDコマンドプロンプトで下記のように入力します。同時にシステムの環境変数に登録しておきます。ホストマシンから仮想イメージへのアクセスIPアドレスはVirtualBoxのHost Only AdaptorのDHCPに依存します。通常は指定IPアドレスの4バイト目が100になり、`192.168.100.1`を指定した場合は`192.168.100.100`がアクセス用IPアドレスになります。ホストからのアクセス用IPアドレスの確認は`docker-runner.bat status`で行えます。

```bat
set MACHINE_STORAGE_PATH=D:\VM\Docker\machine
set DOCKER_RUNNER_PATH=D:\VM\Docker
set DOCKER_RUNNER_WEBAPPS_PATH=D:\VM\webapps

cd /d %DOCKER_RUNNER_PATH%\centos6
docker-runner.bat create

rem IPアドレスを指定する場合
docker-runner.bat --net=192.168.100.1 create

rem ヘルプメッセージ表示
docker-runner.bat help

rem 英語ヘルプメッセージ表示
docker-runner.bat --en help
docker-runner.bat --lang=en help

rem 確認
docker-runner.bat status
```


ヘルプメッセージの言語はWindowsコマンドプロンプトで使用している言語（コードページ）に依存します。仮想マシン内で使用する`docker-runner`のヘルプメッセージの言語も同様です。使用できる言語は英語と日本語のみです。

Docker仮想マシン作成が完了したら、仮想マシン内で仮想イメージを作成します。ログインと同時に仮想マシン用の`docker-runner`に必要なセットアップを行います。

```bat
docker-runner.bat login
```



#### Docker仮想イメージ作成

Docker仮想イメージのビルド可能なイメージは`php53, php54, php55, php56, mysql56, tomcat7`です。全てビルドするにはかなり時間がかかるため、必要なイメージのみをビルドしたほうがよいです。最低限の準備はこれで完了です。完了したらブラウザやCURLでIPアドレスを入力して確認します。

phpサービスは80,443ポートを使用しているため一度に複数を起動することはできません。docker-runner start allで起動した場合はphp56のみが最終的に起動されます。

```bash
docker-runner start all

# 下記のようにしても同じです
docker-runner build all
docker-runner start all

# 仮想サービスへログイン
docker-runner login php56

# ヘルプメッセージ表示
docker-runner help

# 英語ヘルプメッセージ表示
docker-runner --en help
docker-runner --lang=en help

# 確認
curl -L http://default.dev
curl -L http://$(docker inspect --format='{{.NetworkSettings.Networks.bridge.IPAddress}}' php56)
```


個別にビルドする場合は下記のようにします。phpをビルド・起動する場合は関連サービスのmysqlも自動的にビルド・起動されます。

```bash
docker-runner start php54 php56

# または

docker-runner start php*
```



#### サーバー環境

`%DOCKER_RUNNER_PATH%\centos6\build\configs`以下に各サーバーの設定ファイルがあります。また、WEBアプリケーションは`%DOCKER_RUNNER_WEBAPPS_PATH%\php, %DOCKER_RUNNER_WEBAPPS_PATH%\tomcat7`にあります。これらはVirtualBoxのshare機能を使って仮想サービスと連動しています。

設定ファイルパスは下記のようにサービスにマウントされています。

```
# ホスト <-> サービス
build\configs\apache22\conf   <-> /etc/httpd/conf
build\configs\apache22\conf.d <-> /etc/httpd/conf.d
build\configs\mysql56         <-> /etc/mysql
build\configs\mysql56         <-> /etc/mysql
build\configs\php各バージョン   <-> /etc/php
build\configs\tomcat7         <-> /tomcat7/conf

# 下記はリンク
/etc/php/php.ini -> /etc/php.ini
/etc/php/conf.d  -> /etc/php.d

# tomcat環境設定
JAVA_HOME=/usr/java/default
CATALINA_BASE=/tomcat7
CATALINA_HOME=/usr/local/stow/tomcat7
```

サーバー起動スクリプトは下記のようにサービスにマウントされています。

```
# ホスト <-> サービス
build\docker-entrypoint-init.d <-> /docker-entrypoint-init.d
```


WEBアプリケーションは下記のようにサービスにマウントされています。

```
# ホスト <-> サービス
webapps\php\apps        <-> /webapps/apps
webapps\tomcat7\webapps <-> /tomcat7/webapps
```


WEBアプリケーション、MySQLデータベースのサービス内のパスは下記のように設定されています。

```
# php
/webapps/apps
/webapps/libs (ユーザライブラリ, サービス起動時にホスト側からコピーされます)

# php pear
/usr/share/pear

# phpモジュール
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





## Windows用docker-runner.batその他オプション

#### 異なる仮想マシン作成

```bat
docker-runner.bat -p centos7 create

rem または

cd /d %DOCKER_RUNNER_PATH%\centos7
docker-runner.bat create

rem IPアドレスを指定する場合
docker-runner.bat --net=192.168.110.1 create
```



#### 仮想マシンスペック指定をして作成

```bat
docker-runner.bat --cpu=4 --mem=4096 create

rem 初期値
docker-runner.bat --cpu=2 --mem=2048 create
```



#### その他

```bat
rem 仮想マシン停止
docker-runner.bat stop

rem 仮想マシン再起動
docker-runner.bat restart
```





## 仮想マシン用docker-runnerその他オプション

#### 起動サービス変更

```bash
# php5.5
docker-runner start php55

# 下記のようにしても同じです
docker-runner stop php56
docker-runner start php55

# ログイン
docker-runner login php55
```


#### ステータス表示

```bash
docker-runner status

# サービスのパフォーマンスを含めて表示
docker-runner status all

# php関連サービスのステータス表示
docker-runner status php*
```


#### 再起動

サーバー設定を変更した場合など再起動が必要な場合は下記のようにします。

```bash
docker-runner restart php56

# 複数サービス再起動
docker-runner restart php56 mysql56
```


パッケージサービスで追加バイナリをインストール・設定した場合は再起動時に削除されてしまいますので注意してください。apache, php, mysql, tomcat以外のサーバー設定を変更した場合も同様です。これらの変更を保存したい場合は--save-as-imagesオプションを使用します。


#### サービスの変更をイメージへ保存

サービスが起動している状態のときは、コンテナに保存されており、サービスの再起動を行う時は仮想イメージからコンテナへサービスを起動します。このため、サービス起動状態のときに変更を加えても再起動すると初期状態に戻ってしまいます。

パッケージサービスで追加バイナリをインストールや、apache, php, mysql, tomcat以外のサーバー設定を変更した場合、これらの変更差分を含めて仮想イメージとして保存したい場合は下記のようにします。

```bash
docker-runner --save-as-images php56

# 変更内容追加
docker-runner --message="変更内容" --save-as-images php56

# 変更歴表示
docker history centos6_php56
```



#### 初期化

不要なパッケージをインストールしたりなどで、サービスが肥大化してしまい初期化が必要な場合は下記のようにします。サーバー設定ファイルや、WEBアプリケーションが保存されているwebapps以下の領域はWindowsに適宜保存されているので初期化には影響されません。

```bash
docker-runner refresh php56
docker-runner refresh mysql56

# 一度に入力することもできます
docker-runner refresh php56 mysql56

# ビルド済みのすべてのphpを初期化する場合
docker-runner refresh php*
```


#### バックアップ

mysqlデータやphpのpear, peclモジュールなどはmysqldb*, phpdata*に保存されているので定期的にバックアップを行います。バックアップ内容を確認したい場合はデバッグオプションを有効にします。

```bash
docker-runner --backup-storages php56 mysql56

# バックアップ内容確認
docker-runner -v --backup-storages php56 mysql56

# 全てのサービスデータをバックアップ
docker-runner --backup-storages all
```


#### リストア

バックアップファイルからサービスデータへリストアしたい場合は下記のようにします。複数指定はできません。

サービスデータ内の保存ディレクトリを変更した場合は、バックアップに保存されているデーターディレクトリのみをリストアし、それ以外は無視します。

```bash
docker-runner --restore-storages php56

# リストア内容表示
docker-runner -v --restore-storages php56

# 指定バックアップファイルのリストア
docker-runner --restore-storages php56 20160101.101024
```



#### 仮想イメージリビルド

サービスとサービスデータをリビルドします。mysqlなどサービスデータを初期化したくない場合は、バックアップを行ってからリビルド後にデータをリストアしてください。また、追加バイナリパッケージをインストールして設定を含めてイメージとして保存していた場合もすべて初期化します。変更した差分を含めてリビルドしたい場合はビルドファイルを変更してからリビルドしてください。ビルドファイルは`build\Dockerfile-*`にあります。

```bash
docker-runner rebuild php56

# 複数サービスをリビルド
docker-runner rebuild php56 mysql56

# mysqlデータベースバックアップ・リビルド・リストア
docker-runner --backup-storages mysql56
docker-runner rebuild mysql56
docker-runner --restore-storages mysql56
```





## How to start docker container with docker command

Open cmd command line as Administrator.

```bash
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

