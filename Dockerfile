# 開発環境
FROM rust:1-buster as develop-stage
WORKDIR /app
RUN cargo install cargo-watch
COPY . .

# ビルド環境
FROM develop-stage as build-stage
RUN cargo build --release

# 本番環境
FROM debian:bullseye-slim as production-stage
COPY --from=build-stage /app/target/release/actix_web_on_cloud_run .
EXPOSE 8080
CMD ["./actix_web_on_cloud_run"]