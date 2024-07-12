#!/bin/bash

# Função para criar usuários
create_users() {
  local REALM_NAME=$1
  local USERS=${2:-[]}  # Inicializa com um array vazio se USERS não for definido

  # Verifica se USERS é um array
  if ! echo "${USERS}" | jq -e 'type == "array"' > /dev/null; then
    echo "USERS não é um array: ${USERS}"
    return
  fi

  for USER in $(echo "${USERS}" | jq -r '.[] | @base64'); do
    _jq() {
      echo "${USER}" | base64 --decode | jq -r "${1}"
    }
    local USERNAME=$(_jq '.username')
    local PASSWORD=$(_jq '.password')
    local USER_ROLES=$(_jq '.roles')
    local USER_GROUPS=$(_jq '.groups')
    if [ -z "$USERNAME" ] || [ -z "$PASSWORD" ]; then
      echo "Erro: Nome de usuário ou senha não definidos"
      exit 1
    fi
    RESPONSE=$(curl -s -o response.txt -w "%{http_code}" -X POST "${KEYCLOAK_URL}/admin/realms/${REALM_NAME}/users" \
      -H "Authorization: Bearer ${TOKEN}" \
      -H "Content-Type: application/json" \
      -d '{
        "username": "'"${USERNAME}"'",
        "enabled": true,
        "credentials": [{
            "type": "password",
            "value": "'"${PASSWORD}"'",
            "temporary": false
        }]
    }')
    if [ "$RESPONSE" -ne 201 ] && [ "$RESPONSE" -ne 204 ]; then
      echo "Erro ao criar usuário: $USERNAME"
      cat response.txt
      exit 1
    fi

    # Obtendo o ID do usuário recém-criado
    USER_ID=$(curl -s -X GET "${KEYCLOAK_URL}/admin/realms/${REALM_NAME}/users?username=${USERNAME}" \
      -H "Authorization: Bearer ${TOKEN}" | jq -r '.[0].id')

    # Atribuindo roles ao usuário
    for ROLE in $(echo "${USER_ROLES}" | jq -r '.[]'); do
      ROLE_ID=$(curl -s -X GET "${KEYCLOAK_URL}/admin/realms/${REALM_NAME}/roles/${ROLE}" -H "Authorization: Bearer ${TOKEN}" | jq -r '.id')
      curl -s -X POST "${KEYCLOAK_URL}/admin/realms/${REALM_NAME}/users/${USER_ID}/role-mappings/realm" \
        -H "Authorization: Bearer ${TOKEN}" \
        -H "Content-Type: application/json" \
        -d '[{
          "id": "'"${ROLE_ID}"'",
          "name": "'"${ROLE}"'"
      }]'
    done

    # Atribuindo grupos ao usuário
    for GROUP in $(echo "${USER_GROUPS}" | jq -r '.[]'); do
      GROUP_ID=$(curl -s -X GET "${KEYCLOAK_URL}/admin/realms/${REALM_NAME}/groups?search=${GROUP}" \
        -H "Authorization: Bearer ${TOKEN}" | jq -r '.[0].id')
      curl -s -X PUT "${KEYCLOAK_URL}/admin/realms/${REALM_NAME}/users/${USER_ID}/groups/${GROUP_ID}" \
        -H "Authorization: Bearer ${TOKEN}" \
        -H "Content-Type: application/json"
    done
  done
}
