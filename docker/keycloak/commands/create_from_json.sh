#!/bin/bash

source ./docker/keycloak/commands/create_realm.sh
source ./docker/keycloak/commands/get_access_token.sh
source ./docker/keycloak/commands/role_exists.sh
source ./docker/keycloak/commands/create_roles.sh
source ./docker/keycloak/commands/create_groups.sh
source ./docker/keycloak/commands/create_users.sh
source ./docker/keycloak/commands/create_clients.sh

# Função principal para ler o JSON e executar as operações
create_from_json() {
  local JSON_FILE=$1
  local DATA=$(cat "${JSON_FILE}")
  
  local REALM_NAME=$(echo "${DATA}" | jq -r '.realm')
  if [ -z "$REALM_NAME" ]; then
    echo "Erro: Nome do realm não definido"
    exit 1
  fi
  local REALM_CONFIG=$(echo "${DATA}" | jq -c '.')
  local ROLES=$(echo "${DATA}" | jq -c '.roles.realm // empty')
  local CLIENT_ROLES=$(echo "${DATA}" | jq -c '.roles.client // empty')
  local GROUPS=$(echo "${DATA}" | jq -c '.groups // empty')
  local USERS=$(echo "${DATA}" | jq -c '.users // empty')
  local CLIENTS=$(echo "${DATA}" | jq -c '.clients // empty')

  echo "Debug: ROLES=${ROLES}"
  echo "Debug: CLIENT_ROLES=${CLIENT_ROLES}"
  echo "Debug: GROUPS=${GROUPS}"
  echo "Debug: USERS=${USERS}"
  echo "Debug: CLIENTS=${CLIENTS}"

  get_access_token

  create_realm "${REALM_CONFIG}"
  [ -n "$ROLES" ] && create_roles "${REALM_NAME}" "${ROLES}"
  [ -n "$GROUPS" ] && create_groups "${REALM_NAME}" "${GROUPS}"
  [ -n "$USERS" ] && create_users "${REALM_NAME}" "${USERS}"
  [ -n "$CLIENTS" ] && create_clients "${REALM_NAME}" "${CLIENTS}"
}