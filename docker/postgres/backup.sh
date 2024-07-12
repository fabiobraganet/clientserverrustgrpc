#!/bin/bash

# Variáveis de ambiente
BACKUP_DIR="/backup"
DATE=$(date +%Y-%m-%d_%H-%M-%S)
BACKUP_NAME="db_backup_$DATE.sql"

# Comando de backup
pg_dump -U ${POSTGRES_USER} -d ${POSTGRES_DB} -F c -f ${BACKUP_DIR}/${BACKUP_NAME}

# Mensagem de sucesso
echo "Backup realizado com sucesso: ${BACKUP_DIR}/${BACKUP_NAME}"
