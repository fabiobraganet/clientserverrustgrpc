#!/bin/bash

DOCKER_COMPOSE_FILE=docker/docker-compose.yml

chmod +x start.sh
chmod +x docker/keycloak/commands/create_clients.sh
chmod +x docker/keycloak/commands/create_from_json.sh
chmod +x docker/keycloak/commands/create_groups.sh
chmod +x docker/keycloak/commands/create_realm.sh
chmod +x docker/keycloak/commands/create_roles.sh
chmod +x docker/keycloak/commands/create_users.sh
chmod +x docker/keycloak/commands/get_access_token.sh
chmod +x docker/keycloak/commands/ImportRealm.sh
chmod +x docker/keycloak/commands/role_exists.sh

if ! [ -x "$(command -v docker-compose)" ]; then
  echo 'Error: docker-compose is not installed.' >&2
  exit 1
fi

echo "Parando todos os contêineres em execução..."
docker-compose -f $DOCKER_COMPOSE_FILE down

echo "Construindo as imagens do Docker..."
docker-compose -f $DOCKER_COMPOSE_FILE build

echo "Subindo os contêineres do Docker..."
docker-compose -f $DOCKER_COMPOSE_FILE up -d

configure_realm() {
  until $(curl --output /dev/null --silent --head --fail http://localhost:6003); do
    echo "Esperando pelo Keycloak..."
    sleep 5
  done
  echo "Configurando o realm..."
  ./docker/keycloak/commands/ImportRealm.sh ./docker/keycloak/commands/00-realm-export.json
}

configure_realm &

echo "Exibindo os logs dos contêineres..."
docker-compose -f $DOCKER_COMPOSE_FILE logs -f
