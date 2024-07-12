#!/bin/bash

# Função para criar o realm
create_realm() {
  local REALM_CONFIG=$1
  local REALM_NAME=$(echo "${REALM_CONFIG}" | jq -r '.realm')
  RESPONSE=$(curl -s -o response.txt -w "%{http_code}" -X POST "${KEYCLOAK_URL}/admin/realms" \
    -H "Authorization: Bearer ${TOKEN}" \
    -H "Content-Type: application/json" \
    -d "${REALM_CONFIG}")
  if [ "$RESPONSE" -ne 201 ] && [ "$RESPONSE" -ne 204 ]; then
    echo "Erro ao criar realm: $REALM_NAME"
    cat response.txt
    exit 1
  fi
}