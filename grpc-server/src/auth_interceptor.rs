use tonic::{Request, Status};
use jsonwebtoken::{decode, DecodingKey, Validation, Algorithm, TokenData};
use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize)]
pub struct Claims {
    pub sub: String,
    pub email: String,
    pub preferred_username: String,
    pub exp: usize,
    pub realm_access: RealmAccess,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct RealmAccess {
    pub roles: Vec<String>,
}

#[derive(Clone)]
pub struct AuthInterceptor {
    pub keycloak_public_key: String,
}

impl AuthInterceptor {
    pub fn new(keycloak_public_key: String) -> Self {
        AuthInterceptor { keycloak_public_key }
    }

    pub fn intercept(&self, mut request: Request<()>) -> Result<Request<()>, Status> {
        let token = match request.metadata().get("authorization") {
            Some(t) => t.to_str().unwrap().replace("Bearer ", ""),
            None => return Err(Status::unauthenticated("No token provided")),
        };

        println!("Received Token: {}", token);  // Adiciona log para verificação

        let decoding_key = DecodingKey::from_rsa_pem(self.keycloak_public_key.as_bytes())
            .map_err(|_| Status::internal("Invalid key format"))?;

        let token_data: TokenData<Claims> = decode::<Claims>(
            &token,
            &decoding_key,
            &Validation::new(Algorithm::RS256),
        ).map_err(|err| {
            println!("Error decoding token: {:?}", err);  // Adiciona log para erros de decodificação
            Status::unauthenticated("Invalid token")
        })?;

        request.extensions_mut().insert(token_data.claims);

        Ok(request)
    }
}
