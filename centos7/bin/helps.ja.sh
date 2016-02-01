#!/bin/ash

usage() {
    echo
    echo -e "  \033[1m使い方\033[0m"
    echo -e "    $0 [\033[4mオプション\033[0m] \033[4mコマンド サービス\033[0m[ サービス1 サービス2 ...]"
    echo
    echo -e "  \033[1mオプション\033[0m"
    echo -e "    \033[4m-en, --en, --english, --lang=en\033[0m"
    echo -e "      ヘルプメッセージの言語を英語に設定します。"
    echo -e "      英語、日本語のみ選択可能です。"
    echo -e "      初期値: 英語"
    echo
    echo -e "    \033[4m-ja, --ja, --japanese, --lang=ja\033[0m"
    echo -e "      ヘルプメッセージの言語を日本語に設定します。"
    echo -e "      英語、日本語のみ選択可能です。"
    echo
    echo -e "    \033[4m-v, --verbose, --debug\033[0m"
    echo -e "      デバッグモードをONにします。"
    echo
    echo -e "    \033[4m--message=\"commit message\", --msg=\"commit message\"\033[0m"
    echo -e "      起動中サービスコンテナをdockerイメージとして保存する時に指定します。"
    echo
    echo -e "  \033[1mコマンド\033[0m"
    echo -e "    \033[4msetup, --setup\033[0m"
    echo -e "      docker-composeのインストール・アップデートを行います。また、"
    echo -e "      自動マウントファイルを設置します。"
    echo -e "       - /var/lib/boot2docker/docker-compose"
    echo -e "       - /var/lib/boot2docker/bootlocal.sh"
    echo -e "       - /var/lib/boot2docker/bootsync.sh"
    echo
    echo -e "    \033[4mbuild, --build\033[0m"
    echo -e "      dockerイメージを作成します。"
    echo
    echo -e "    \033[4mstart, --start\033[0m"
    echo -e "      サービス・データコンテナと、依存しているサービス含めて起動します。"
    echo -e "      もしdockerイメージが存在しない場合は、自動的に作成します。"
    echo
    echo -e "    \033[4mlogin, --login\033[0m"
    echo -e "      起動済みサービス・データコンテナにログインします。"
    echo
    echo -e "    \033[4mstop, --stop\033[0m"
    echo -e "      サービスを停止してコンテナから削除します。データコンテナは含みません。"
    echo -e "      追加パッケージをインストールした場合は削除されます。"
    echo -e "      サービスコンテナの現在の状態を維持したい場合は、コンテナをイメージとして保存して"
    echo -e "      ください。"
    echo -e "      例）docker.sh --save-as-images php56"
    echo
    echo -e "    \033[4mstatus, --status\033[0m"
    echo -e "      サービスのステータスを表示します。"
    echo -e "      表示内容）docker images, docker ps -a, docker stats"
    echo
    echo -e "    \033[4mrestart, --restart\033[0m"
    echo -e "      サービスを停止してコテンテナから削除した後、サービス・依存サービスを含めて起動します。"
    echo -e "      データコンテナは含みません。"
    echo
    echo -e "    \033[4mrefresh, --refresh\033[0m"
    echo -e "      サービスを停止してコテンテナから削除した後、サービス・依存サービスを含めて起動します。"
    echo -e "      データコンテナを含みます。"
    echo
    echo -e "    \033[4mrebuild, --rebuild\033[0m"
    echo -e "      データコンテナを含むサービスを停止して、コテンテナから削除した後、dockerイメージ"
    echo -e "      を削除します。データコンテナを含むサービスのdockerイメージを再度作成します。"
    echo
    echo -e "    \033[4mhelp, --help\033[0m"
    echo -e "      本メッセージを表示します。"
    echo
    echo -e "    \033[4m--delete-storages\033[0m"
    echo -e "      データコンテナを含むサービスを停止して、コテンテナから削除します。"
    echo -e "      「refresh」コマンドに似ていますが、サービスの起動は行いません。"
    echo
    echo -e "    \033[4m--delete-images\033[0m"
    echo -e "      データコンテナを含むサービスを停止して、コテンテナから削除した後、dockerイメージ"
    echo -e "      を削除します。ベースイメージ（centos/dev）も削除可能です。"
    echo
    echo -e "    \033[4m--backup-storages\033[0m"
    echo -e "      データコンテナに保存されたデータをtarファイルにバックアップします。"
    echo
    echo -e "    \033[4m--restore-storages\033[0m"
    echo -e "      最新のtarファイルに保存されたバックアップデータをデータコンテナにリストアします。"
    echo -e "      このコマンドは複数サービスには対応していません。"
    echo -e "      特定のバックアップファイルをリストアしたい場合は、ファイル名の部分文字列である
    echo -e "      「日時」を指定します。"
    echo -e "      ex) docker-runner --restore-storages php56 20160101.101024"
    echo
    echo -e "    \033[4m--save-as-images\033[0m"
    echo -e "      現在の起動中のサービスコンテナをdockerイメージとして保存します。(docker commit)"
    echo -e "      ex) docker-runner --message=\"commit message\" --save-as-images php56"
    echo
    echo -e "  \033[1mサービス\033[0m"
    echo -e "      利用可能サービス : \033[4mall, php*, mysql*, tomcat*, mysql56, tomcat7\033[0m"
    echo -e "      \033[4m, php53, php54, php55, php56\033[0m"
    echo -e "      PHPサービスは、80ポート・443ポートを使用しているため複数起動できません。"
    echo
    exit 1
}
