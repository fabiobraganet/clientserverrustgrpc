#!/bin/bash

# Função para verificar se a role já existe
role_exists() {
  local REALM_NAME=$1
  local ROLE_NAME=$2
  RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -X GET "${KEYCLOAK_URL}/admin/realms/${REALM_NAME}/roles/${ROLE_NAME}" \
    -H "Authorization: Bearer ${TOKEN}")
  if [ "$RESPONSE" -eq 200 ]; then
    return 0
  else
    return 1
  fi
}
