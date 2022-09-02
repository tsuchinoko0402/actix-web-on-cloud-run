# 開発環境
FROM rust:1-buster as develop-stage
WORKDIR /app
RUN cargo install cargo-watch
COPY . .

# ビルド環境
FROM develop-stage as build-stage
RUN cargo build --release

# 本番環境
FROM scratch:latest
COPY --from=build-stage /home/rust/target/x86_64-unknown-linux-musl/release/actix_web_sample . 
EXPOSE 8080
ENTRYPOINT [ "./actix_web_sample" ] 