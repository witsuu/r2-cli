mod config;
mod r2_client;

use clap::{Parser, Subcommand};
use config::R2Config;
use dialoguer::Input;
use dotenvy::dotenv;
use r2_client::R2Client;
use reqwest;
use serde_json::Value;
use std::error::Error;

/// Simple Cloudflare R2 CLI
#[derive(Parser)]
#[command(author, version, about)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// Download a file from R2
    Download {
        #[arg(short, long)]
        bucket: String,
        #[arg(short, long)]
        key: String,
        #[arg(short, long)]
        output: String,
    },
    /// Upload a file to R2
    Upload {
        #[arg(short, long)]
        bucket: String,
        #[arg(short, long)]
        file: String,
        #[arg(short, long)]
        key: String,
    },
    Update,
    Configure,
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn Error>> {
    dotenv().ok();
    let cli = Cli::parse();

    match cli.command {
        Commands::Download {
            bucket,
            key,
            output,
        } => {
            let r2 = R2Client::new(bucket).await?;
            r2.download(&key, &output).await?;
        }
        Commands::Upload { bucket, file, key } => {
            let r2 = R2Client::new(bucket).await?;
            r2.upload(&file, &key).await?;
        }
        Commands::Update => {
            r2cli_update().await?;
        }
        Commands::Configure => {
            configure_r2cli().await?;
        }
    }

    Ok(())
}

async fn configure_r2cli() -> Result<(), Box<dyn std::error::Error>> {
    let access_key: String = Input::new()
        .with_prompt("Enter your R2 Access Key ID")
        .interact_text()?;

    let secret_key: String = Input::new()
        .with_prompt("Enter your R2 Secret Access Key")
        .interact_text()?;

    let account_id: String = Input::new()
        .with_prompt("Enter your R2 Account ID")
        .interact_text()?;

    let r2config = R2Config {
        access_key,
        secret_key,
        account_id,
    };

    let mut config_path = dirs::config_dir().ok_or("Cannot find config directory")?;
    config_path.push("r2cli");

    tokio::fs::create_dir_all(&config_path).await?;

    config_path.push("config.toml");

    let toml_data = toml::to_string_pretty(&r2config)?;
    tokio::fs::write(config_path, toml_data).await?;

    println!("✅ R2CLI configured successfully!");

    Ok(())
}

async fn r2cli_update() -> Result<(), Box<dyn std::error::Error>> {
    let github_user = "username"; // <-- ganti ini
    let repo_name = "r2cli"; // <-- ganti ini
    let url = format!(
        "https://api.github.com/repos/{}/{}/releases/latest",
        github_user, repo_name
    );

    let client = reqwest::Client::new();
    let res = client
        .get(&url)
        .header("User-Agent", "r2cli-updater")
        .send()
        .await?
        .json::<Value>()
        .await?;

    let tag = res["tag_name"].as_str().ok_or("Failed to get tag_name")?;

    println!("⬇️ Updating to latest version: {}", tag);

    let platform = if cfg!(target_os = "linux") {
        "x86_64-unknown-linux-musl"
    } else if cfg!(target_os = "macos") && cfg!(target_arch = "aarch64") {
        "aarch64-apple-darwin"
    } else if cfg!(target_os = "macos") {
        "x86_64-apple-darwin"
    } else if cfg!(windows) {
        "x86_64-pc-windows-gnu"
    } else {
        return Err("Unsupported platform".into());
    };

    let mut download_url = format!(
        "https://github.com/{}/{}/releases/download/{}/r2cli-{}",
        github_user, repo_name, tag, platform
    );

    if cfg!(windows) {
        download_url.push_str(".exe");
    }

    println!("📦 Downloading from: {}", download_url);

    let resp = client.get(&download_url).send().await?.bytes().await?;

    let current_exe = std::env::current_exe()?;
    tokio::fs::write(&current_exe, &resp).await?;

    println!("✅ Updated! Restart your shell if needed.");

    Ok(())
}
