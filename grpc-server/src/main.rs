use tonic::transport::Server;
use tonic::codegen::InterceptedService;

mod auth_interceptor;

pub mod my_service {
    tonic::include_proto!("my_service");
}

use my_service::my_service_server::{MyService, MyServiceServer};
use my_service::{MyRequest, MyResponse};
use auth_interceptor::AuthInterceptor;

#[derive(Default)]
pub struct MyServiceImpl;

#[tonic::async_trait]
impl MyService for MyServiceImpl {
    async fn my_rpc_method(
        &self,
        request: tonic::Request<MyRequest>,
    ) -> Result<tonic::Response<MyResponse>, tonic::Status> {
        let claims: &auth_interceptor::Claims = request.extensions().get().unwrap();
        println!("Authenticated user: {}", claims.email);

        Ok(tonic::Response::new(MyResponse {
            code: 200,
            message: "Request successful".into(),
        }))
    }
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let keycloak_public_key = include_str!("../keycloak_public_key.pem");
    let auth_interceptor = AuthInterceptor::new(keycloak_public_key.to_string());

    let my_service = MyServiceImpl::default();

    let intercepted_service = InterceptedService::new(
        MyServiceServer::new(my_service),
        move |req| auth_interceptor.clone().intercept(req),
    );

    Server::builder()
        .add_service(intercepted_service)
        .serve("127.0.0.1:50051".parse().unwrap())
        .await?;

    Ok(())
}
