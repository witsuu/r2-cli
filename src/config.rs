use serde::Deserialize;
use serde::Serialize;
use std::env;
use std::fs;

#[derive(Debug, Deserialize, Serialize)]
pub struct R2Config {
    pub access_key: String,
    pub secret_key: String,
    pub account_id: String,
}

impl R2Config {
    pub fn load() -> Result<Self, Box<dyn std::error::Error>> {
        // Coba dari ENV dulu
        if let (Ok(access_key), Ok(secret_key), Ok(account_id)) = (
            env::var("R2_ACCESS_KEY_ID"),
            env::var("R2_SECRET_ACCESS_KEY"),
            env::var("R2_ACCOUNT_ID"),
        ) {
            return Ok(R2Config {
                access_key,
                secret_key,
                account_id,
            });
        }

        // Kalau ENV gagal, coba dari file
        let mut config_path = dirs::config_dir().ok_or("Cannot find config directory")?;
        config_path.push("r2cli/config.toml");

        let content = fs::read_to_string(&config_path)?;
        let config: R2Config = toml::from_str(&content)?;

        Ok(config)
    }
}
