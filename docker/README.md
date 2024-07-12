# Docker
> **Importante!**   
> *Aqui a documentação sobre a estrutura do docker e os seus serviços.*   
> **Como este documento é aproveitado de outro projeto meu. Você vai precisar ajustar o Realm ou criar um novo no Keycloak incluindo client e usuário.** 
 

---

**Bem-vindo**! Este README fornece uma visão geral da funcionalidade do sistema, focando especialmente na configuração dos serviços Docker e no script de inicialização `start.sh`.

## Sumário

- [Visão Geral](#visão-geral)
- [Estrutura do Docker](#estrutura-do-docker)
- [Configuração do Docker](#configuração-do-docker)
- [Acessando o PostgreSQL](#acessando-o-postgresql)
- [Script de Backup do PostgreSQL](#script-de-backup-do-postgresql)
- [Carga Inicial do Keycloak](#carga-inicial-do-keycloak)
- [Script de Inicialização](#script-de-inicialização)
- [Instruções de Uso](#instruções-de-uso)

## Visão Geral

O **DigitalVault** é uma plataforma robusta que oferece soluções completas para o gerenciamento seguro e eficiente de ativos digitais. Com uma arquitetura baseada em microserviços e utilizando tecnologias como Keycloak, PostgreSQL, Minio e RabbitMQ, a plataforma garante escalabilidade, segurança e desempenho.

## Estrutura do Docker

A estrutura de diretórios do Docker está organizada para facilitar a configuração e a manutenção dos diversos serviços que compõem a plataforma. Aqui está uma visão geral dos principais componentes e arquivos:

```
docker/
    ├── keycloak/
    │   ├── Dockerfile
    │   └── commands/
    │       ├── create_clients.sh
    │       ├── get_access_token.sh
    │       ├── create_groups.sh
    │       ├── create_roles.sh
    │       ├── ImportRealm.sh
    │       ├── create_realm.sh
    │       ├── create_users.sh
    │       └── create_from_json.sh
    ├── postgres/
    │   ├── Dockerfile
    │   └── backup.sh
    ├── rabbitmq/
    │   └── Dockerfile
    ├── minio/
    │   └── Dockerfile
    └── docker-compose.yml
```

## Configuração do Docker

O arquivo `docker-compose.yml` é o núcleo da configuração do Docker, definindo como os serviços são orquestrados. Aqui estão os principais serviços configurados:

- **PostgreSQL**: Banco de dados relacional utilizado pelo Keycloak para armazenar informações de autenticação. [Documentação Oficial](https://www.postgresql.org/docs/)
- **Keycloak**: Servidor de identidade e gerenciamento de acesso que fornece autenticação e autorização para as aplicações. [Documentação Oficial](https://www.keycloak.org/documentation)
- **Minio**: Serviço de armazenamento de objetos compatível com Amazon S3, ideal para armazenar grandes volumes de dados. [Documentação Oficial](https://docs.min.io/)
- **RabbitMQ**: Sistema de mensagens que facilita a comunicação entre os diversos componentes da plataforma. [Documentação Oficial](https://www.rabbitmq.com/documentation.html)

## Serviços Utilizados

Aqui estão os ícones dos principais serviços utilizados na plataforma DigitalVault com links para a documentação oficial de cada produto:

<a href="https://www.postgresql.org/docs/" target="_blank">
  <img src="https://cdn-icons-png.flaticon.com/64/5968/5968342.png" alt="PostgreSQL" width="64" height="64">
</a>
<a href="https://www.keycloak.org/documentation" target="_blank">
  <img src="https://static.wixstatic.com/media/de11f1_7b361763f89e4d08afeab683a7740ebe~mv2.png/v1/fit/w_500,h_500,q_90/file.png" alt="Keycloak" width="64" height="64">
</a>
<a href="https://docs.min.io/" target="_blank">
  <img src="https://blog.alexellis.io/content/images/2017/01/minio_light_cir_sm-1.png" alt="Minio" width="64" height="64">
</a>
<a href="https://www.rabbitmq.com/documentation.html" target="_blank">
  <img src="https://jpadilla.github.io/rabbitmqapp/assets/img/icon.png" alt="RabbitMQ" width="64" height="64">
</a>

### Exemplo de Configuração (docker-compose.yml)

O arquivo `docker-compose.yml` inclui a configuração detalhada de cada serviço, como portas, variáveis de ambiente e volumes persistentes.

## Acessando o PostgreSQL

Após a inicialização dos serviços, você pode acessar o PostgreSQL utilizando as seguintes credenciais:

- **Host**: localhost
- **Porta**: 6010
- **Usuário**: administrator
- **Senha**: administrator
- **Banco de Dados**: KeyCloakDB

Para se conectar ao banco de dados, você pode utilizar um cliente PostgreSQL de sua preferência, como o [pgAdmin](https://www.pgadmin.org/) ou o [psql](https://www.postgresql.org/docs/current/app-psql.html).

## Script de Backup do PostgreSQL

O serviço de PostgreSQL inclui um script de backup (`backup.sh`) que é executado diariamente via cron job. Este script cria um backup do banco de dados e o armazena no diretório `/backup`.

### Localização do Script

O script de backup está localizado em `docker/postgres/backup.sh` e é configurado para rodar às 2:00 AM todos os dias.

### Exemplo de Backup

Ao ser executado, o script gera um arquivo de backup com o nome `db_backup_<data-e-hora>.sql` no diretório `/backup`. 

## Carga Inicial do Keycloak

A configuração inicial do Keycloak inclui a criação de um realm padrão (`DigitalVault`) e a importação de usuários, grupos, roles e clientes a partir de um arquivo JSON (`00-realm-export.json`). Este processo é automatizado através de um conjunto de scripts localizados em `docker/keycloak/commands/`.

### Arquivo de Exportação do Realm

O arquivo `00-realm-export.json` contém todas as definições iniciais do realm, incluindo configurações de segurança, políticas de senha e entidades de usuário.

### Script de Importação

O script `ImportRealm.sh` é utilizado para importar todas as configurações do JSON para o Keycloak. Este script deve ser executado após a inicialização dos contêineres.

## Script de Inicialização

O `start.sh` é um script essencial que facilita o processo de inicialização e configuração do ambiente Docker. Ele automatiza a execução do `docker-compose` para garantir que todos os serviços sejam iniciados corretamente.

## Instruções de Uso

1. **Clonar o Repositório**: Clone o repositório DigitalVault em sua máquina local.

   ```sh
   git clone https://github.com/seu-usuario/digitalvault.git
   cd digitalvault
   ```

2. **Configurar Variáveis de Ambiente**: Edite as variáveis de ambiente no arquivo `.env` conforme necessário.

3. **Executar o Script de Inicialização**: Utilize o script `start.sh` para iniciar todos os serviços Docker.

   ```sh
   ./start.sh
   ```

4. **Acessar os Serviços**: Após a inicialização, os serviços estarão acessíveis nas seguintes URLs:
   - **Keycloak**: 6011 [Console em http://localhost:6000](http://localhost:6000)
   - **Minio**: 6012 [Console em http://localhost:6001](http://localhost:6001)
   - **RabbitMQ**: 6013 [Console em http://localhost:6002](http://localhost:6002)
   - **PostgreSQL**: 6010 ***com os detalhes de acesso fornecidos acima***

