#!/bin/bash

# Definições das variáveis
KEYCLOAK_URL="http://localhost:6003"
ADMIN_USER="administrator"
ADMIN_PASSWORD="administrator"
JSON_FILE_PATH="$1"

# Importar funções
source ./docker/keycloak/commands/create_from_json.sh

# Chamando a função principal com o caminho do JSON
create_from_json "${JSON_FILE_PATH}"

echo "Realm, roles, groups, users, and clients created successfully from JSON."
