use actix_web::{HttpResponse, get, post, put, HttpServer, App, web::{self, Json}};
use actix_web_on_cloud_run::{config::CONFIG, crud::{create_post, show_posts, publish_post}, models::RequestPost};
use diesel::{
    r2d2::{ConnectionManager, Pool},
    PgConnection,
};
use anyhow::{Context, Result};

#[get("/")]
async fn index() -> Result<HttpResponse, actix_web::Error> {
    let response_body = "Hello, World!!";

    Ok(HttpResponse::Ok().body(response_body))
}

#[post("/post")]
async fn post_post(
    data: web::Data<RequestContext>,
    request: Json<RequestPost>,
) -> Result<HttpResponse, actix_web::Error> {
    let title = &request.title;
    let body = &request.body;

    let mut conn = data.pool.get().context("failed to get connection").unwrap();
    create_post(&mut conn, &title, &body).unwrap();
    Ok(HttpResponse::Ok().body("Ok"))
}

#[get("/posts")]
async fn get_posts(
    data: web::Data<RequestContext>,
) -> Result<HttpResponse, actix_web::Error> {
    let mut conn = data.pool.get().context("failed to get connection").unwrap();
    let posts = show_posts(&mut conn);
    Ok(HttpResponse::Ok().json(posts))
}

#[put("/post/{id}")]
async fn post_id(
    data: web::Data<RequestContext>,
    path_params: web::Path<(i32,)>,
) -> Result<HttpResponse, actix_web::Error>  {
    let mut conn = data.pool.get().context("failed to get connection").unwrap();
    let id = path_params.into_inner().0;
    let _post = publish_post(&mut conn, id);
    Ok(HttpResponse::Ok().body(format!("ID: {} is published.", id)))
}

#[actix_rt::main]
async fn main() -> Result<(), actix_web::Error> {
    let port = std::env::var("PORT")
        .ok()
        .and_then(|val| val.parse::<u16>().ok())
        .unwrap_or(CONFIG.port);
        
    HttpServer::new(move || {
        App::new()
            .app_data(web::Data::new(RequestContext::new()).clone())
            .service(index)
            .service(post_post)
            .service(get_posts)
            .service(post_id)
        })
        .bind(format!("{}:{}", CONFIG.server_address, port))?
        .run()
        .await?;
    Ok(())
}

#[derive(Clone)]
pub struct RequestContext {
    pool: Pool<ConnectionManager<PgConnection>>,
}

impl RequestContext {
    pub fn new() -> RequestContext {
        let manager = ConnectionManager::<PgConnection>::new(&CONFIG.database_url);
        let pool = Pool::builder()
            .build(manager)
            .expect("Failed to create DB connection pool.");

        RequestContext { pool }
    }
}