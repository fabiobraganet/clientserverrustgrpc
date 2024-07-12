fn main() -> Result<(), Box<dyn std::error::Error>> {
    tonic_build::configure()
        .build_client(true)
        .compile(&["src/proto/my_service.proto"], &["src/proto"])?;
    Ok(())
}