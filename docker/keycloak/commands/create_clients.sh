#!/bin/bash

# Função para criar clientes
create_clients() {
  local REALM_NAME=$1
  local CLIENTS=${2:-[]}  # Inicializa com um array vazio se CLIENTS não for definido

  # Verifica se CLIENTS é um array
  if ! echo "${CLIENTS}" | jq -e 'type == "array"' > /dev/null; then
    echo "CLIENTS não é um array: ${CLIENTS}"
    return
  fi

  for CLIENT in $(echo "${CLIENTS}" | jq -r '.[] | @base64'); do
    _jq() {
      echo "${CLIENT}" | base64 --decode | jq -r "${1}"
    }
    local CLIENT_ID=$(_jq '.clientId')
    local CLIENT_SECRET=$(_jq '.secret')
    local CLIENT_PERMISSIONS=$(_jq '.permissions')
    local CLIENT_MAPPERS=$(_jq '.mappers')
    if [ -z "$CLIENT_ID" ] || [ -z "$CLIENT_SECRET" ]; then
      echo "Erro: ID ou segredo do cliente não definidos"
      exit 1
    fi
    if client_exists "${REALM_NAME}" "${CLIENT_ID}"; then
      echo "O cliente ${CLIENT_ID} já existe no realm ${REALM_NAME}"
      continue
    fi
    RESPONSE=$(curl -s -o response.txt -w "%{http_code}" -X POST "${KEYCLOAK_URL}/admin/realms/${REALM_NAME}/clients" \
      -H "Authorization: Bearer ${TOKEN}" \
      -H "Content-Type: application/json" \
      -d '{
        "clientId": "'"${CLIENT_ID}"'",
        "secret": "'"${CLIENT_SECRET}"'",
        "enabled": true,
        "directAccessGrantsEnabled": true,
        "redirectUris": ["http://localhost:8080/*"]
    }')
    if [ "$RESPONSE" -ne 201 ] && [ "$RESPONSE" -ne 204 ]; then
      echo "Erro ao criar cliente: $CLIENT_ID"
      cat response.txt
      exit 1
    fi

    # Obtendo o ID do cliente recém-criado
    CLIENT_UUID=$(curl -s -X GET "${KEYCLOAK_URL}/admin/realms/${REALM_NAME}/clients?clientId=${CLIENT_ID}" \
      -H "Authorization: Bearer ${TOKEN}" | jq -r '.[0].id')

    # Adicionando permissões ao cliente
    for PERMISSION in $(echo "${CLIENT_PERMISSIONS}" | jq -r '.[]'); do
      RESPONSE=$(curl -s -o response.txt -w "%{http_code}" -X POST "${KEYCLOAK_URL}/admin/realms/${REALM_NAME}/clients/${CLIENT_UUID}/authz/resource-server/permission" \
        -H "Authorization: Bearer ${TOKEN}" \
        -H "Content-Type: application/json" \
        -d "${PERMISSION}")
      if [ "$RESPONSE" -ne 201 ] && [ "$RESPONSE" -ne 204 ]; then
        echo "Erro ao adicionar permissão ao cliente: $CLIENT_ID"
        cat response.txt
        exit 1
      fi
    done

    # Adicionando mappers ao cliente
    for MAPPER in $(echo "${CLIENT_MAPPERS}" | jq -r '.[] | @base64'); do
      _jq() {
        echo "${MAPPER}" | base64 --decode | jq -r "${1}"
      }
      local MAPPER_NAME=$(_jq '.name')
      local MAPPER_TYPE=$(_jq '.type')
      local MAPPER_CONFIG=$(_jq '.config')
      RESPONSE=$(curl -s -o response.txt -w "%{http_code}" -X POST "${KEYCLOAK_URL}/admin/realms/${REALM_NAME}/clients/${CLIENT_UUID}/protocol-mappers/models" \
        -H "Authorization: Bearer ${TOKEN}" \
        -H "Content-Type: application/json" \
        -d '{
          "name": "'"${MAPPER_NAME}"'",
          "protocol": "openid-connect",
          "protocolMapper": "'"${MAPPER_TYPE}"'",
          "config": '"${MAPPER_CONFIG}"'
      }')
      if [ "$RESPONSE" -ne 201 ] && [ "$RESPONSE" -ne 204 ]; then
        echo "Erro ao adicionar mapper ao cliente: $CLIENT_ID"
        cat response.txt
        exit 1
      fi
    done
  done
}
