# AWS Aurora, AppSync Terraform Infrastructure

このTerraformプロジェクトは、AWS上でAurora、AppSyncを使ったインフラストラクチャを構築し、GraphQL APIからデータベースに直接アクセスできるようにします。

## 構成

- **VPC**: プライベートサブネットとパブリックサブネットを含むVPC
- **Aurora**: MySQL 8.0のAuroraクラスター（ライター1台、リーダー1台）
- **AppSync**: GraphQL API（API Key認証）
- **Secrets Manager**: データベース認証情報の管理
- **IAM**: AppSyncからAuroraへのアクセス権限

## GraphQL API機能

### Query
- `hello`: 簡単な挨拶メッセージ
- `activities`: 全アクティビティの取得
- `activitiesByUser(author: String!)`: 特定ユーザーのアクティビティ取得
- `buys`: 全購入履歴の取得
- `buysByUser(author: String!)`: 特定ユーザーの購入履歴取得

### Mutation
- `createActivity(author: String!, timestamp: String!, weather: String, health: String, steps: Int!)`: 新規アクティビティの作成
- `createBuy(author: String!, timestamp: String!, item_name: String!, item_price: Int!)`: 新規購入履歴の作成

## データベーススキーマ

### activity テーブル
- `id`: アクティビティID (VARCHAR(255), PRIMARY KEY, UUID)
- `author`: 作成者ID (VARCHAR(255))
- `timestamp`: タイムスタンプ (DATETIME)
- `weather`: 天気情報 (JSON)
- `health`: 健康情報 (JSON)
- `steps`: 歩数 (INT)

### buy テーブル
- `id`: 購入ID (VARCHAR(255), PRIMARY KEY, ULID)
- `author`: 購入者ID (VARCHAR(255))
- `timestamp`: 購入日時 (DATETIME)
- `item_name`: アイテム名 (VARCHAR(255))
- `item_price`: アイテム価格 (INT)

## 使用方法

### 1. 設定ファイルの準備

```bash
# terraform.tfvars.exampleをコピーして実際の値を設定
cp terraform.tfvars.example terraform.tfvars
```

`terraform.tfvars`ファイルを編集して、実際のパスワードや設定値を入力してください。

### 2. Terraformの初期化

```bash
terraform init
```

### 3. プランの確認

```bash
make plan
```

### 4. インフラの作成

```bash
make apply
```

### 5. データベースの初期化

Prismaを用いてデータベースを初期化：

```bash
npx prisma migrate dev
```

### 6. GraphQL APIのテスト

AppSyncコンソールまたはGraphQLクライアントで以下のクエリをテストできます：

```graphql
# アクティビティ一覧の取得
query {
  activities {
    id
    author
    timestamp
    weather
    health
    steps
  }
}

# 特定ユーザーのアクティビティ取得
query {
  activitiesByUser(author: "user1") {
    id
    timestamp
    steps
    weather
    health
  }
}

# 購入履歴一覧の取得
query {
  buys {
    id
    author
    timestamp
    item_name
    item_price
  }
}

# 特定ユーザーの購入履歴取得
query {
  buysByUser(author: "user1") {
    id
    timestamp
    item_name
    item_price
  }
}

# 新規アクティビティの作成
mutation {
  createActivity(
    author: "user1"
    timestamp: "2024-01-15T10:30:00Z"
    weather: "{\"temp\": 25, \"condition\": \"sunny\"}"
    health: "{\"heart_rate\": 75}"
    steps: 8000
  ) {
    id
    author
    steps
    weather
    health
  }
}

# 新規購入履歴の作成
mutation {
  createBuy(
    author: "user1"
    timestamp: "2024-01-15T14:00:00Z"
    item_name: "New Surfboard"
    item_price: 60000
  ) {
    id
    author
    item_name
    item_price
  }
}
```

### 7. インフラの削除（必要に応じて）

```bash
terraform destroy
```

## 出力値

インフラ構築後、以下の情報が出力されます：

- **Aurora**: クラスターエンドポイント、リーダーエンドポイント、ポート
- **AppSync**: GraphQL URL、API Key
- **Secrets Manager**: データベース認証情報のARN

## セキュリティ

- データベースはプライベートサブネットに配置
- セキュリティグループでポート3306のみ許可
- ストレージは暗号化済み
- パスワードはSecrets Managerで管理
- AppSyncからAuroraへのアクセスはIAMロールで制御

## アーキテクチャ

```
Client → AppSync → IAM Role → Aurora Cluster
                ↓
            Secrets Manager (認証情報)
```

## コスト最適化

- Aurora: `db.r6g.large`（本番環境向け）
- 必要に応じてインスタンスクラスを調整してください

## 注意事項

- この設定は開発環境向けです
- 本番環境では、より強固なセキュリティ設定が必要です
- パスワードは必ず安全な値に変更してください
- バックアップ設定は7日間保持に設定されています
- データベース初期化は手動で実行する必要があります

## トラブルシューティング

### よくある問題

1. **VPC CIDR重複**: 既存のVPCとCIDRが重複している場合は、`vpc_cidr`を変更してください
2. **サブネットCIDR重複**: 既存のサブネットとCIDRが重複している場合は、`private_subnets`や`public_subnets`を変更してください
3. **インスタンスクラス**: リージョンによって利用できないインスタンスクラスがある場合は、適切なクラスに変更してください
4. **GraphQLエラー**: データベーステーブルが存在しない場合は、`init-database.sql`を実行してください

### ログの確認

```bash
# Terraformのログを詳細に表示
export TF_LOG=DEBUG
terraform apply
``` 