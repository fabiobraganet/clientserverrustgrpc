#!/bin/bash

# Função para criar grupos
create_groups() {
  local REALM_NAME=$1
  local GROUPS=${2:-"[]"}

  # Verifica se GROUPS é um array
  if ! echo "${GROUPS}" | jq -e 'type == "array"' > /dev/null; then
    echo "GROUPS não é um array: ${GROUPS} (pode ignorar)"
    return
  fi

  for GROUP in $(echo "${GROUPS}" | jq -r '.[] | @base64'); do
    _jq() {
      echo "${GROUP}" | base64 --decode | jq -r "${1}"
    }
    local GROUP_NAME=$(_jq '.name')
    local GROUP_ATTRIBUTES=$(_jq '.attributes')
    if [ -z "$GROUP_NAME" ]; then
      echo "Erro: Nome do grupo não definido"
      exit 1
    fi
    RESPONSE=$(curl -s -o response.txt -w "%{http_code}" -X POST "${KEYCLOAK_URL}/admin/realms/${REALM_NAME}/groups" \
      -H "Authorization: Bearer ${TOKEN}" \
      -H "Content-Type: application/json" \
      -d '{
        "name": "'"${GROUP_NAME}"'",
        "attributes": '"${GROUP_ATTRIBUTES}"'
    }')
    if [ "$RESPONSE" -ne 201 ] && [ "$RESPONSE" -ne 204 ]; then
      echo "Erro ao criar grupo: $GROUP_NAME"
      cat response.txt
      exit 1
    fi
  done
}
