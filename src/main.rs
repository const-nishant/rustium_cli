use rustium_cli::{RustiumError, interactive_mode};

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let rt = tokio::runtime::Runtime::new().unwrap();
    Ok(rt.block_on(async_main())?)
}

async fn async_main() -> Result<(), RustiumError> {
    // Always run in interactive mode
    interactive_mode().await
}
