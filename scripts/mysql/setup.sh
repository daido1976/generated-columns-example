#!/bin/bash

# create-table.sql を実行して users テーブルを作成
docker compose exec mysql mysql -u root --password=root -D generated_columns_example -e "$(cat "$(dirname "$0")/create-table.sql")"

# 一度に処理するレコードの数（多すぎると argument list too long が出る）
BATCH_SIZE=2000

# コマンドライン引数で指定したレコード数を取得
RECORD_COUNT=${1:-$BATCH_SIZE}

# スクリプトの開始時間を取得
START_TIME=$(date +%s)

# usersテーブルに指定した数のレコードを追加
for ((i=1; i<=RECORD_COUNT; i+=BATCH_SIZE))
do
  QUERY="INSERT INTO users (email, last_login_at) VALUES "
  # バッチサイズごとにランダムなドメインを生成
  DOMAIN=$(LC_ALL=C tr -dc '[:lower:]' < /dev/urandom | fold -w 6 | head -n 1)
  for ((j=i; j<i+BATCH_SIZE && j<=RECORD_COUNT; j++))
  do
    QUERY+="('email$j@$DOMAIN.com', NOW()),"
  done
  QUERY=${QUERY%?}  # Remove trailing comma
  docker compose exec mysql mysql -u root --password=root -D generated_columns_example -e "$QUERY"
  echo "Inserted records up to $j into users table"
  # 経過時間を出力
  ELAPSED_TIME=$(($(date +%s) - START_TIME))
  echo "Elapsed time: $ELAPSED_TIME seconds"
done

# スクリプトの終了時間を取得し、経過時間を計算
END_TIME=$(date +%s)
TOTAL_ELAPSED_TIME=$((END_TIME - START_TIME))
echo "Total elapsed time: $TOTAL_ELAPSED_TIME seconds"
