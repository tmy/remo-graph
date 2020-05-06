#
# S3 に保存された履歴データを Athena で検索できるようにする
#

# Glue でカタログデータベースを作ると Athena にも反映される
resource "aws_glue_catalog_database" "history" {
  name = var.app_name
}

# Athena のテーブルを Glue のデータカタログ経由で定義する
# テーブル定義の内容はクローラを使うと自動定義できるが、お金がかかるので手動で定義する
resource "aws_glue_catalog_table" "history" {
  database_name = aws_glue_catalog_database.history.name
  name          = "history"
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    classification = "json"
  }

  storage_descriptor {
    location      = "s3://${aws_s3_bucket.history.id}/data/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"

    ser_de_info {
      name                  = "org.openx.data.jsonserde.JsonSerDe"
      serialization_library = "org.openx.data.jsonserde.JsonSerDe"
      parameters = {
        paths = "created_at,firmware_version,humidity_offset,id,mac_address,name,newest_events,serial_number,temperature_offset,timestamp,updated_at,users"
      }
    }

    columns {
      name = "name"
      type = "string"
    }
    columns {
      name = "id"
      type = "string"
    }
    columns {
      name = "created_at"
      type = "string"
    }
    columns {
      name = "updated_at"
      type = "string"
    }
    columns {
      name = "mac_address"
      type = "string"
    }
    columns {
      name = "serial_number"
      type = "string"
    }
    columns {
      name = "firmware_version"
      type = "string"
    }
    columns {
      name = "temperature_offset"
      type = "int"
    }
    columns {
      name = "humidity_offset"
      type = "int"
    }
    columns {
      name = "users"
      type = "array<struct<id:string,nickname:string,superuser:boolean>>"
    }
    columns {
      name = "newest_events"
      type = "struct<hu:struct<val:int,created_at:string>,il:struct<val:double,created_at:string>,mo:struct<val:int,created_at:string>,te:struct<val:double,created_at:string>>"
    }
    columns {
      name = "timestamp"
      type = "string"
    }
  }
}
