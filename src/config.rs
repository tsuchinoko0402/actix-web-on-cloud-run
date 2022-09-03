use dotenv::dotenv;
use once_cell::sync::Lazy;
use serde::Deserialize;

/// .evnの内容を保存するstruct
#[derive(Deserialize, Debug)]
pub struct AppConfig {
    pub server_address: String,
    pub server_port: u16,
}

/// static変数の初期化          
pub static CONFIG: Lazy<AppConfig> = Lazy::new(|| {
    dotenv().ok();
    config::Config::builder()
        .add_source(
            config::Environment::default(),
        )
        .build()
        .unwrap()
        .try_deserialize()
        .unwrap()
});
