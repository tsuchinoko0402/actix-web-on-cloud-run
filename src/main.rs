mod config;

use actix_web::{HttpResponse, get, HttpServer, App};
use crate::config::CONFIG;

#[get("/")]
async fn index() -> Result<HttpResponse, actix_web::Error> {
    let response_body = "Hello, World!!";

    Ok(HttpResponse::Ok().body(response_body))
}

#[actix_rt::main]
async fn main() -> Result<(), actix_web::Error> {
    let port = std::env::var("PORT")
        .ok()
        .and_then(|val| val.parse::<u16>().ok())
        .unwrap_or(CONFIG.port);
        
    HttpServer::new(move || App::new().service(index))
        .bind(format!("{}:{}", CONFIG.server_address, port))?
        .run()
        .await?;
    Ok(())
}
