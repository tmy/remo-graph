# remo-graph

Nature Remo のセンサーデータを AWS 上で継続的に取得します。


## 作成される機能

  * 5 分毎に Nature Remo のデバイス情報を取得
  * CloudWatch のメトリクスに気温・湿度・照度・人感データを記録
  * CloudWatch Dashboard で気温・湿度・照度・人感グラフを表示
  * S3 のバケットにデバイス情報の履歴を記録
  * 履歴検索用 Athena テーブル

## 必要なもの

  * terraform

## インストール

`terraform.tfvars` ファイルを作成して以下のように設定

```tf
nature_remo_api_key = "Nature Remo の API キー"
```

terraform を実行してリソースを作成

```
$ terraform apply

...

Outputs:

dashboard-url = [CloudWatch Dashboard の URL]
```
