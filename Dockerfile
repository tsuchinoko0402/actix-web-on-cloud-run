# 開発環境
FROM rust:1-buster as develop-stage
WORKDIR /app
RUN cargo install cargo-watch
COPY . .

# ビルド環境
FROM ekidd/rust-musl-builder:stable as build-stage
WORKDIR /home/rust
COPY . .
RUN cargo build --release

# 本番環境
FROM alpine:latest as production-stage
WORKDIR /actix-web-on-cloud-run
COPY --from=build-stage /home/rust/target/x86_64-unknown-linux-musl/release/actix-web-on-cloud-run . 
EXPOSE 8080
ENTRYPOINT [ "./actix-web-on-cloud-run" ] 