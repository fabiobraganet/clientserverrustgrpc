#!/bin/bash

# Função para obter token de acesso
get_access_token() {
  TOKEN=$(curl -s -X POST "${KEYCLOAK_URL}/realms/master/protocol/openid-connect/token" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "username=${ADMIN_USER}" \
    -d "password=${ADMIN_PASSWORD}" \
    -d 'grant_type=password' \
    -d 'client_id=admin-cli' | jq -r '.access_token')
  if [ -z "$TOKEN" ]; then
    echo "Erro ao obter token de acesso"
    exit 1
  fi
}
