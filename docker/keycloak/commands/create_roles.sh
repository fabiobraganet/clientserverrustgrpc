#!/bin/bash

# Função para criar roles
create_roles() {
  local REALM_NAME=$1
  local ROLES=$2

  # Verifica se ROLES é um array
  if ! echo "${ROLES}" | jq -e 'type == "array"' > /dev/null; then
    echo "ROLES não é um array: ${ROLES}"
    return
  fi

  for ROLE in $(echo "${ROLES}" | jq -r '.[] | @base64'); do
    _jq() {
      echo "${ROLE}" | base64 --decode | jq -r "${1}"
    }
    local ROLE_NAME=$(_jq '.name')
    local ROLE_DESCRIPTION=$(_jq '.description')
    if [ -z "$ROLE_NAME" ]; then
      echo "Erro: Nome da role não definido"
      exit 1
    fi
    if role_exists "${REALM_NAME}" "${ROLE_NAME}"; then
      echo "A role ${ROLE_NAME} já existe no realm ${REALM_NAME}"
      continue
    fi
    RESPONSE=$(curl -s -o response.txt -w "%{http_code}" -X POST "${KEYCLOAK_URL}/admin/realms/${REALM_NAME}/roles" \
      -H "Authorization: Bearer ${TOKEN}" \
      -H "Content-Type: application/json" \
      -d '{
        "name": "'"${ROLE_NAME}"'",
        "description": "'"${ROLE_DESCRIPTION}"'"
    }')
    if [ "$RESPONSE" -ne 201 ] && [ "$RESPONSE" -ne 204 ]; then
      echo "Erro ao criar role: $ROLE_NAME"
      cat response.txt
      exit 1
    fi
  done
}
