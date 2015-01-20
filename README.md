# comp_if_devtool

互換IFを動作確認することができるツールです。  
sinatraアプリケーションです。

### ツールを動かす

[comp_IF_paramlist_gen](https://github.com/ValLaboratory/comp_IF_paramlist_gen) を実行して作られる入出力パラメータリスト  
*  v2apiDevTool/intrav3 
 * input_params     #ディレクトリ
 * output_params   #ディレクトリ
 * v2APIs.yml

が必要なので用意する。

* 必要なGem(sinatra, erbis, rack, unicorn あたり) を gem install する
* git clone https://github.com/ValLaboratory/comp_if_devtool.git
* \cp -rf v2apiDevTool/intrav3/* v3_development/v2apiDevTool/data/api/
* lib/v2apiDevTool/config/app_config.yml に互換IF（Webサービス）のアクセスキーのデフォルト値を設定できるので設定する
* unicorn.conf を作成する

unicorn.confの例
```
listen 4567 ,:tcp_nodelay=>true       # 公開するポートをここに書く
worker_processes 1
stderr_path "log/unicorn_error.log"
stdout_path "log/unicorn_out.log"
preload_app false
timeout 300
pid "./unicorn.pid"
```
* unicorn -c unicorn.conf  で起動する。デーモン起動は -D オプションをつける
* ブラウザで http://xxx.xxx.xxx.xxx:4567/v2apiDevToolV3/ にアクセスする

### jcgi系を動かす時の注意点

jcgiにキックするときにproxyを通すかどうかチェックボックスで指定できるので  
ツールを設置する環境に合わせて指定を変えてください。

### 変更が必要なタイミング

互換IFの入出力パラメータ、APIの増減に合わせて変更するのがベストだが  
互換IFの社内向け補助ツールという位置づけなうえに、イントラV２とは違って互換IFは単体でも  
全てのインターフェース(cgi_で始まるもの含む)を動かすことが可能なので、特にクリティカルなタイミングは存在しない。  
shift-jisでマルチバイトコードを送るときに便利なくらい。


### ソースの勘所

##### 入力パラメータの設定とその並び順

* lib/v2apiDevTool/data/view/input_order.yml

##### 出力パラメータの設定とその並び順

* lib/v2apiDevTool/data/view/output_order.yml

##### インターフェースの増減

* lib/v2apiDevTool/data/view/menu_order.yml    #トップ画面のメニュー （追加した実績がないです。）

