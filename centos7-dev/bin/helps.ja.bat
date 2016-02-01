REM
REM CAUTION
REM This file is encoded by Shift_JIS (code page: 932)
REM
echo;
echo   使い方
echo     %_BIN% [オプション] コマンド
echo;
echo   オプション
echo     -en, --en, --english, --lang=en
echo       ヘルプメッセージの言語を英語に設定します。
echo       英語、日本語のみ選択可能です。
echo       初期値: 英語
echo;
echo     -ja, --ja, --japanese, --lang=ja
echo       ヘルプメッセージの言語を日本語に設定します。
echo       英語、日本語のみ選択可能です。
echo;
echo     -v, --debug
echo       デバッグモードをONにします。
echo;
echo     --cpu, --cpu-count [number]
echo       使用CPUを設定します。
echo       dockerマシンを新規作成時に一緒に使用します。
echo;
echo     --mem, --memory [number(MB)]
echo       使用メモリを設定します。
echo       dockerマシンを新規作成時に一緒に使用します。
echo;
echo     --net, --network [ip]
echo       VirtualBoxが作成する「host only network adapter」のIPアドレスを設定します。
echo       dockerマシンへのアクセス用IPアドレスは静的に「192.168.xx.100～192.168.xx.254」
echo       と決められています。どのIPアドレスを使用するかはDHCPに依存します。
echo       dockerマシンを新規作成時に一緒に使用します。
echo;
echo   コマンド
echo     help
echo       本メッセージを表示します。
echo;
echo     create
echo       dockerマシンを作成した後、VirtualBox用の共有ディレクトリを設定します。
echo       dockerマシンを起動します。
echo;
echo     delete, rm
echo       dockerマシンをディレクトリを含めて削除します。
echo;
echo     share
echo       VirtualBox用の共有ディレクトリを設定します。設定は、「bin\docker-runner.conf」
echo       の［shared］セクションにあります。
echo       dockerマシンを起動します。
echo;
echo     start
echo       dockerマシンを起動します。
echo;
echo     login
echo       dockerマシンにログインします。
echo;
echo     stop
echo       dockerマシンを停止します。
echo;
echo     restart
echo       dockerマシンを再起動します。
echo;
echo     status, ls
echo       dockerマシンのステータスを表示します。
echo;
