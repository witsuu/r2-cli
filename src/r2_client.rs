use aws_sdk_s3::config::Credentials;
use aws_sdk_s3::primitives::ByteStream;
use aws_sdk_s3::Client;
use aws_types::region::Region;
// use futures_util::StreamExt;
use futures_util::stream::StreamExt;
use indicatif::{ProgressBar, ProgressStyle};
use tokio::io::AsyncWriteExt;
use tokio_util::io::ReaderStream;

use crate::config::R2Config;

/// R2Client struct untuk mengelola operasi Cloudflare R2
pub struct R2Client {
    client: Client,
    bucket: String,
}

impl R2Client {
    /// Membuat client baru berdasarkan bucket
    pub async fn new(bucket: String) -> Result<Self, Box<dyn std::error::Error>> {
        let cfg = R2Config::load()?;

        let endpoint_url = format!("https://{}.r2.cloudflarestorage.com", cfg.account_id);

        let shared_config = aws_config::load_defaults(aws_config::BehaviorVersion::latest()).await;

        let config = aws_sdk_s3::config::Builder::from(&shared_config)
            .endpoint_url(endpoint_url)
            .credentials_provider(Credentials::new(
                cfg.access_key,
                cfg.secret_key,
                None,
                None,
                "custom-loaded",
            ))
            .region(Region::new("auto"))
            .build();

        let client = Client::from_conf(config);

        Ok(Self { client, bucket })
    }

    /// Download file dari R2
    pub async fn download(
        &self,
        key: &str,
        output_path: &str,
    ) -> Result<(), Box<dyn std::error::Error>> {
        let resp = self
            .client
            .get_object()
            .bucket(&self.bucket)
            .key(key)
            .send()
            .await?;

        let total_size = resp.content_length();

        let pb = if let Some(size) = total_size {
            let pb = ProgressBar::new(size as u64);
            pb.set_style(
                ProgressStyle::default_bar()
                    .template("{spinner:.green} [{elapsed_precise}] [{bar:40.cyan/blue}] {bytes}/{total_bytes} ({eta})")
                    .unwrap()
                    .progress_chars("#>-"),
            );
            Some(pb)
        } else {
            None
        };

        let body = resp.body.into_async_read();
        let mut stream = ReaderStream::new(body);

        let mut file = tokio::fs::File::create(output_path).await?;

        while let Some(bytes) = stream.next().await {
            let chunk = bytes?;
            file.write_all(&chunk).await?;
            if let Some(pb) = &pb {
                pb.inc(chunk.len() as u64);
            }
        }

        if let Some(pb) = pb {
            pb.finish_with_message("✅ Download completed");
        } else {
            println!("✅ Download completed (no size info)");
        }

        println!("✅ Downloaded '{}' to '{}'", key, output_path);
        Ok(())
    }

    /// Upload file ke R2
    pub async fn upload(
        &self,
        file_path: &str,
        key: &str,
    ) -> Result<(), Box<dyn std::error::Error>> {
        let data = tokio::fs::read(file_path).await?;

        self.client
            .put_object()
            .bucket(&self.bucket)
            .key(key)
            .body(ByteStream::from(data))
            .send()
            .await?;

        println!("✅ Uploaded '{}' as '{}'", file_path, key);
        Ok(())
    }
}
