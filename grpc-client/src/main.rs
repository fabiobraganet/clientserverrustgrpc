use tonic::transport::Channel;
use tonic::Request;
use reqwest::Client;
use serde::{Deserialize, Serialize};
use std::time::Duration;

pub mod my_service {
    tonic::include_proto!("my_service");
}

use my_service::my_service_client::MyServiceClient;
use my_service::MyRequest;

#[derive(Debug, Serialize, Deserialize)]
struct KeycloakTokenResponse {
    access_token: String,
}

async fn get_token() -> Result<String, Box<dyn std::error::Error>> {
    let client = Client::new();
    let res = client.post("http://localhost:6003/realms/grpcteste/protocol/openid-connect/token")
        .form(&[
            ("client_id", "grpc-client"),
            ("client_secret", "JqPgjkO7q8slO0FR1ByHNzwpopoJVMMQ"), // Substitua pelo seu client_secret
            ("grant_type", "password"),
            ("username", "user"),
            ("password", "user"),
        ])
        .send()
        .await?
        .json::<KeycloakTokenResponse>()
        .await?;

    Ok(res.access_token)
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let token = get_token().await?;

    let endpoint = Channel::from_static("http://127.0.0.1:50051")
        .connect_timeout(Duration::from_secs(5)) // Adiciona timeout para conexão
        .timeout(Duration::from_secs(5))         // Adiciona timeout para requisições
        .connect()
        .await?;

    let mut client = MyServiceClient::new(endpoint);

    let mut request = Request::new(MyRequest {
        name: "teste cliente".into(),
        id: 1,
    });

    request.metadata_mut().insert("authorization", format!("Bearer {}", token).parse().unwrap());

    let response = client.my_rpc_method(request).await?;

    println!("RESPONSE={:?}", response);

    Ok(())
}
