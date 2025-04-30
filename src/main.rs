use std::net::SocketAddr;

use chrono::{offset::TimeZone, Utc};
use clap::Parser;
use tokio::{io::AsyncWriteExt, net::TcpListener};

#[derive(Debug, Parser)]
struct Cli {
    #[clap(default_value = "0.0.0.0:37")]
    host: SocketAddr,
}

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let rfc868_basetime = Utc.with_ymd_and_hms(1900, 1, 1, 0, 0, 0).unwrap();
    let rt = tokio::runtime::Builder::new_current_thread().build()?;
    tracing_subscriber::fmt::init();
    let c = Cli::parse();

    rt.block_on(async move {
        let listener = TcpListener::bind(c.host).await?;
        let addr = listener.local_addr()?;
        tracing::info!("Server is ready on {addr}");

        loop {
            let (mut socket, addr) = listener.accept().await?;
            tracing::info!("Accept request from: {addr}");

            tokio::spawn(async move {
                let current_rfc868_time = (Utc::now() - rfc868_basetime).num_seconds() as i32;

                if let Err(v) = socket.write_all(&current_rfc868_time.to_be_bytes()).await {
                    tracing::info!("Something went wrong: {v}");
                };
            });
        }
    })
}
