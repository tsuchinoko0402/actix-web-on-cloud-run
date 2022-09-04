# Web API サーバー on Rust サンプル

- Rust で実装した Web API サーバーのサンプル。

## 必要要件

- Docker
- docker-compose
- Rust
- diesel

```term
$ cd server
$ cargo install 
```

## 使い方

### ビルド方法

```term
docker-compose build
```

### 起動方法

```term
docker-compose up -d
```

### 終了方法

```term
docker-compose down
```

## 動作例

```term
$ curl -X POST -H "Content-Type: application/json" -d '{"title": "title1", "body": "body_example"}' localhost:8080/post
Ok

$ curl -X POST -H "Content-Type: application/json" -d '{"title": "title2", "body": "hugahuga"}' localhost:8080/post
Ok

$ curl -X GET localhost:8080/posts
[]

$ curl -X PUT localhost:8080/post/1
ID: 1 is published.

$ curl -X GET localhost:8080/posts 
[{"id":1,"title":"title1","body":"body_example","is_published":true}]
```

## データマイグレーション方法

diesel の CLI ツールを使う

```term
$ cargo install diesel_cli --no-default-features --features postgres
```

ここで、もし以下のようなエラーが出た場合：
```
note: ld: library not found for -libpq
clang: error: linker command failed with exit code 1 (use -v to see invocation)
```
libpq のライブラリがインストールされていないので、各 OS の環境に合わせてインストールする。

`.env` の `DATABASE_URL` は `docker-compose` 用に設定されているため、`diesel setup` や `diesel migration generate create_table` を行う際は、手元で環境変数を設定する：

```term
$ export DATABASE_URL=postgres://admin:password@localhost:5432/postgres
```