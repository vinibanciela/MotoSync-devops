# MotoSync API - Documentação Oficial

**LINK DO VIDEO**: [[MotoSync]]()

**MotoSync** é uma API RESTful desenvolvida em Java com Spring Boot para o gerenciamento inteligente de motos em pátios da empresa Mottu. Integrando tecnologias modernas e recursos de autenticação, o sistema permite organização e rastreamento das motos de forma segura, com integração com dispositivos IoT e um aplicativo mobile.

---

## 📚 Visão Geral

A aplicação resolve o problema da desorganização de motos nos pátios da empresa, automatizando o processo de alocação de vagas, leitura de entradas e saídas com sensores RFID, controle por operadores e gestão de registros de movimentação.

---

## ⚙️ Tecnologias Utilizadas

- **Java 21**
- **Spring Boot**
- **Spring Data JPA**
- **Spring Security + JWT**
- **Spring Cache**
- **ThymeLeaf**
- **Azure (SQL, ACR, ACI, Pipelines)**

---

### 🧠 Entidades e Funcionalidades

## 🏢 Pátio (/patios)

GET /patios – lista pátios

GET /patios/{id} – pátio por ID

GET /patios/cidade/{cidade} – filtra por cidade

POST /patios – cria pátio
Campos: nome, rua, numero, bairro, cidade, estado, pais

## 📍 Vaga (/vagas)

GET /vagas – lista vagas

GET /vagas/{id} – por ID

GET /vagas/patio/{patioId}/status/{status} – por pátio e status (OCUPADA, LIVRE)

POST /vagas – cria vaga
Campos: coordenadaLat, coordenadaLong, status, patioId, motoId

## 🏍️ Moto (/motos)

GET /motos – lista motos

GET /motos/{id} – por ID

GET /motos/placa/{placa} – por placa

POST /motos – cria moto
Campos: placa, marca, modelo, cor, vagaId

## 📡 Leitor (/leitores)

GET /leitores – lista leitores

GET /leitores/{id} – por ID

GET /leitores/patio/{patioId} – por pátio

GET /leitores/vaga/{vagaId}/tipo/{tipo} – por vaga e tipo

POST /leitores – cria leitor
Campos: tipo (ENTRADA | VAGA), vagaId, patioId

## 🧾 Registro (/registros)

GET /registros – lista registros

GET /registros/moto/{motoId} – por moto

GET /registros/moto/{motoId}/tipo/{tipo} – por moto + tipo (ENTRADA | SAIDA)

GET /registros/periodo?inicio=...&fim=... – por período

POST /registros – cria registro
Campos: motoId, leitorId, tipo, dataHora

---

## 🔐 Segurança (JWT + Regras de Escopo)

Login API: POST /api/auth/login → retorna accessToken (JWT).

Uso: enviar Authorization: Bearer <token> nas rotas privadas.

Regras:

ADMIN: acesso total.

OPERADOR_PATIO: tudo filtrado pelo pátio do usuário (aplicado nos Services e Repositories).

---

## ▶️ Guia de Execução Local

1. Clone o projeto:

```bash
1 - Clone e Abra o Projeto
git clone https://github.com/vinibanciela/MotoSync-devops.git
cd MotoSync-devops

2 - Limpe o Projeto, Compile e Empacote o Arquivo executável .Jar com Gradle
.\gradlew clean bootJar

3 - Contrua a Imagem Docker e Tagueie
docker build -t motosync-api:local .

4 - Rode o Container com as Variáveis Preenchidas
docker run --rm `
  -p <PORTA_LOCAL>:<PORTA_CONTAINER> `
  --name <NOME_CONTAINER_LOCAL> `
  -e DB_URL="<STRING_DE_CONEXAO_DO_BANCO>" `
  -e DB_DRIVER="<DRIVER_DO_BANCO>" `
  -e DB_USER="<USUARIO_DO_BANCO>" `
  -e DB_PASSWORD="<SENHA_DO_BANCO>" `
  -e DB_DIALECT="<DIALETO_DO_HIBERNATE>" `
  -e APP_JWT_SECRET="<CHAVE_SECRETA_JWT>" `
  -e GITHUB_CLIENT_ID="<CLIENT_ID_GITHUB>" `
  -e GITHUB_CLIENT_SECRET="<CLIENT_SECRET_GITHUB>" `
  -e GOOGLE_CLIENT_ID="<CLIENT_ID_GOOGLE>" `
  -e GOOGLE_CLIENT_SECRET="<CLIENT_SECRET_GOOGLE>" `
  <NOME_IMAGEM>:local

5 - Acesse em:
http://localhost:8081/login

6 - Pare e Remova o Container, e Remova a Imagem Docker
docker stop motosync-api-local
docker rm motosync-api-local
docker rmi motosync-api:local

```

## 🚀 Guia de Deploy (Ambiente Production - Nuvem)

```bash
1 - Entrar na conta da Azure

az login


2 - Criar o AzureSQL - Server e Database (PAAS)

az group create --name <NOME_DO_RESOURCE_GROUP_DATABASE> --location <LOCALIZACAO>
az sql server create -l <LOCALIZACAO> -g <NOME_DO_RESOURCE_GROUP_DATABASE> -n <NOME_DO_SQL_SERVER> -u <USUARIO_ADMIN> -p <SENHA_ADMIN> --enable-public-network true
az sql db create -g <NOME_DO_RESOURCE_GROUP_DATABASE> -s <NOME_DO_SQL_SERVER> -n <NOME_DO_DATABASE> --service-objective <TIPO_PLAN> --backup-storage-redundancy <TIPO_BACKUP> --zone-redundant false
az sql server firewall-rule create -g <NOME_DO_RESOURCE_GROUP_DATABASE> -s <NOME_DO_SQL_SERVER> -n AllowAll --start-ip-address 0.0.0.0 --end-ip-address 255.255.255.255
az sql db show-connection-string -s <NOME_DO_SQL_SERVER> -n <NOME_DO_DATABASE> -c jdbc


Obs: é preciso guardar essa URL para configurar na pipeline.

3 - Registrar, Criar o Azure Container Registry, Fazer Login, Mostrar Credenciais de Acesso

az provider register --namespace Microsoft.ContainerRegistry
az group create --name <NOME_DO_RESOURCE_GROUP_ACR> --location <LOCALIZACAO>
az acr create --resource-group <NOME_DO_RESOURCE_GROUP_ACR> --name <NOME_DO_ACR> --sku Standard --admin-enabled true --public-network-enabled true
az acr login --name <NOME_DO_ACR>
az acr show --name <NOME_DO_ACR> --resource-group <NOME_DO_RESOURCE_GROUP_ACR> --query loginServer --output tsv
az acr credential show --name <NOME_DO_ACR> --query username -o tsv
az acr credential show --name <NOME_DO_ACR> --query passwords[0].value -o tsv


Obs: é preciso guardar essas credenciais do ACR para configurar o ACI.

4 - Clonar e Abrir o Projeto do Github na sua Máquina

git clone <URL_DO_REPOSITORIO>
cd <NOME_DIRETORIO_PROJETO>


5 - Construir a imagem Docker, Taguear e Subir para o ACR

docker build -t <NOME_IMAGEM> .
docker tag <NOME_IMAGEM> <ACR_LOGIN_SERVER>/<REPOSITORIO_ACR>
docker push <ACR_LOGIN_SERVER>/<REPOSITORIO_ACR>


6 - Registrar o ACI e Criar um Grupo de Recursos para o ACI da Pipeline
Obs: apenas registramos o serviço e criamos um grupo de recursos separado dos demais recursos; a criação do ACI será feita via pipeline.

az provider register --namespace Microsoft.ContainerInstance
az group create --name <NOME_DO_RESOURCE_GROUP_ACI> --location <LOCALIZACAO>


7 - Configuração das Pipelines na Azure

ETAPA 1 — Criar sua organization

Organization > Settings > Parallel Jobs → verificar se está ativo

Organization > Settings > Settings (Pipeline) → marcar “Disable creation of classic build pipelines”

Organization > Settings > Settings (Pipeline) → marcar “Disable creation of classic release pipelines”

ETAPA 2 — Criar projeto
Na sua Organization → Criar Novo Projeto:

Visibility: Private

Version control: Git

Work item process: Scrum

Nome e descrição conforme desejar.

ETAPA 3 — Criar as Service Connections necessárias
Vá em Project Settings → Service connections → New service connection

A. Azure Resource Manager (para o ACI)

Tipo: Azure Resource Manager

Credential: Workload Identity Federation

Scope: Subscription

Subscription: selecionar a que contém os recursos criados

Connection name: <NOME_DA_SERVICE_CONNECTION_ACI>

Grant access permission to all pipelines.
Obs: usada pela task AzureCLI@2 no deploy.

B. Docker Registry (para o ACR)

Tipo: Docker Registry

Registry type: Azure Container Registry

Authentication type: Service principal

Scope: Subscription

Azure Container Registry: selecione <NOME_DO_ACR>

Connection name: <NOME_DA_SERVICE_CONNECTION_ACR>

Grant access permission to all pipelines.
Obs: usada pela task Docker@3 para o build/push da imagem.

ETAPA 4 — Criar a pipeline no Azure DevOps

Vá até o seu projeto no Azure DevOps

Clique em Pipelines > New Pipeline

Escolha Azure Repos Git (YAML)

Selecione o repositório com o projeto

Escolha Existing Azure Pipelines YAML file

Selecione o arquivo azure-pipelines.yml na raiz

Salve e clique em Run.

ETAPA 5 — Criar os grupos de variáveis comuns e secretas (Library)
Vá em Pipelines → Library → + Variable group

Grupo de variáveis secretas (cadeado fechado):

Nome: <NOME_GRUPO_SECRETO>
APP_JWT_SECRET="<CHAVE_JWT>"
DB_PASSWORD="<SENHA_DO_BANCO>"
GITHUB_CLIENT_SECRET="<CLIENT_SECRET_GITHUB>"
GOOGLE_CLIENT_SECRET="<CLIENT_SECRET_GOOGLE>"
passwordACR="<SENHA_ACR>"


Grupo de variáveis comuns (cadeado aberto):

Nome: <NOME_GRUPO_COMUM>
azureSubscription="<NOME_DA_SERVICE_CONNECTION_ACI>"
containerDnsNameACI="<DNS_ACI>"
containerNameACI="<NOME_CONTAINER_ACI>"
containerRegistry="<ACR_LOGIN_SERVER>"
cpuACI="<QUANTIDADE_CPU>"
DB_DIALECT="<DIALETO_DO_BANCO>"
DB_DRIVER="<DRIVER_DO_BANCO>"
DB_URL="<STRING_DE_CONEXAO_DO_BANCO>"
DB_USER="<USUARIO_DO_BANCO>"
dockerRegistryServiceConnection="<NOME_DA_SERVICE_CONNECTION_ACR>"
GITHUB_CLIENT_ID="<CLIENT_ID_GITHUB>"
GOOGLE_CLIENT_ID="<CLIENT_ID_GOOGLE>"
imageRepository="<REPOSITORIO_ACR>"
memoryACI="<TAMANHO_MEMORIA>"
resourceGroupACI="<NOME_DO_RESOURCE_GROUP_ACI>"
systemOperacionalACI="<SISTEMA_OPERACIONAL>"
usernameACR="<USUARIO_ACR>"
vmImageName="<IMAGEM_VM>"


8 - Acessar a aplicação:

<ENDERECO_DNS_ACI>:<PORTA>/login
```

A aplicação sobe em http://localhost:8081/login

## Web (Thymeleaf):

Home: http://localhost:8081/

Login: http://localhost:8081/login

Cadastro (operador): http://localhost:8081/register

## API: http://localhost:8081/api/\*\*

Login: POST /api/auth/login

Usuários de exemplo (dev):

ADMIN: thiago@email.com / 123456

OPERADOR: lgsreal@gmail.com / 123456

## 🧭 Perfis e UI (resumo)

ADMIN vê/edita tudo (pátios, vagas, motos, leitores, registros).

OPERADOR_PATIO só vê/atua no seu pátio.

As telas Thymeleaf (navbar/footer/head) servem de prova funcional das regras e incluem CSRF.

## 🧰 Troubleshooting

403 / dados “de outro pátio” → verifique o papel do usuário e o patioId associado.

401 → faltou header Authorization.

CSRF em formulários web → certifique-se de incluir o token ${\_csrf.parameterName} / ${\_csrf.token}.

Oracle não conecta → confira porta/serviço (ex.: XEPDB1) e credenciais.

## 👨‍💻 Autores

Projeto desenvolvido por :
**Thiago Mendes** — RM 555352

**Guilherme Gonçalves** - RM 558475

**Vinicius Banciela** - RM 558117

---
