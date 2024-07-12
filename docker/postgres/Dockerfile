FROM postgres:16

# Copia o script de backup para o contêiner
COPY backup.sh /usr/local/bin/backup.sh

# Instala o cron
RUN apt-get update && apt-get install -y cron

# Adiciona a tarefa cron
RUN echo "0 2 * * * root /usr/local/bin/backup.sh" >> /etc/cron.d/backup-cron

# Permissões do script
RUN chmod +x /usr/local/bin/backup.sh

# Aplica permissões corretas e inicializa o cron
RUN touch /var/log/cron.log
CMD cron && tail -f /var/log/cron.log
