# Pipeline de CI/CD - Kube-News

Guia completo para configurar e usar o pipeline de CI/CD no Azure DevOps.

## 📋 Arquivos Criados

- **Dockerfile** — Imagem Docker multi-stage otimizada
- **azure-pipelines.yml** — Pipeline de CI/CD no Azure DevOps
- **docker-compose.yml** — Ambiente local para testes
- **manifests/deployment.yml** — Deployment Kubernetes
- **manifests/service.yml** — Service Kubernetes

## 🚀 Como Usar

### 1. Testar Localmente com Docker Compose

```bash
# Subir ambiente local
docker-compose up -d

# Verificar saúde
curl http://localhost:8080/health

# Ver logs
docker-compose logs -f kubenews

# Derrubar ambiente
docker-compose down
```

### 2. Configurar Azure DevOps

#### Pré-requisitos
- Conta no Azure DevOps
- Azure Container Registry (ACR)
- Azure Kubernetes Service (AKS) clusters

#### Passos

**1. Criar Serviço de Conexão com ACR**
```
Azure DevOps → Project Settings → Service connections → New service connection
→ Docker Registry → Azure Container Registry
```

**2. Criar Ambientes**
```
Pipelines → Environments → Create environment
→ dev (para branch develop)
→ production (para branch main)
```

**3. Criar Conexão com AKS**
```
Azure DevOps → Project Settings → Service connections → New service connection
→ Kubernetes
→ Configurar para dev e prod clusters
```

**4. Adicionar Pipeline**
```
Pipelines → Create pipeline → GitHub/Azure Repos
→ Selecionar repositório
→ Existing Azure Pipelines YAML file
→ Selecionar azure-pipelines.yml
```

### 3. Configurar Variáveis

No Azure DevOps, edite o pipeline e configure:

```yaml
dockerRegistryServiceConnection: 'your-acr-connection-name'
imageRepository: 'kubenews'
containerRegistry: 'youracr.azurecr.io'
```

**Ou use as Variáveis do Pipeline:**
- Vá em Edit → Variables
- Adicione `REGISTRY_CONNECTION`, `REGISTRY_NAME`, etc.

### 4. Configurar Secrets no Kubernetes

Para cada cluster (dev/prod):

```bash
# Criar secret com credenciais do banco
kubectl create secret generic kubenews-secrets \
  --from-literal=db-host=postgres.example.com \
  --from-literal=db-port=5432 \
  --from-literal=db-database=kubedevnews \
  --from-literal=db-username=kubedevnews \
  --from-literal=db-password=YourSecurePassword \
  -n default

# Para produção
kubectl create secret generic kubenews-secrets \
  --from-literal=db-host=prod-postgres.example.com \
  --from-literal=db-port=5432 \
  --from-literal=db-database=kubedevnews \
  --from-literal=db-username=kubedevnews \
  --from-literal=db-password=YourSecurePassword \
  -n kubenews
```

## 📊 Fluxo do Pipeline

```
main/develop branch push
        ↓
    BUILD STAGE
    ├─ Checkout
    ├─ Node.js setup
    ├─ npm install
    ├─ Docker build
    └─ Push to ACR (apenas main)
        ↓
    SECURITY STAGE
    ├─ Trivy image scan
    └─ Check vulnerabilities
        ↓
    DEPLOY STAGE
    ├─ develop → Deploy Dev
    ├─ main → Deploy Production
    └─ Rolling update
```

## 🔐 Boas Práticas de Segurança

✅ **Implementado:**
- Imagem Docker multi-stage (menor tamanho)
- Container rodando como non-root
- Liveness e Readiness probes
- Resource limits
- Pod Anti-Affinity para alta disponibilidade
- Read-only root filesystem
- Scanning com Trivy (disponível)

**Próximos passos:**
- Configure RBAC no Kubernetes
- Implemente Network Policies
- Configure Azure Policies
- Configure Container Registry scanning

## 🧪 Testando Localmente

### Verificar Build Docker

```bash
# Build imagem
docker build -t kubenews:test .

# Rodar container
docker run -p 8080:8080 \
  -e DB_HOST=postgres \
  -e DB_USERNAME=kubedevnews \
  -e DB_PASSWORD=Pg#123 \
  kubenews:test
```

### Validar Manifests Kubernetes

```bash
# Validar YAML
kubectl apply -f manifests/deployment.yml --dry-run=client

# Verificar recursos necessários
kubectl apply -f manifests/ --dry-run=client -o wide
```

## 📈 Monitoramento

A aplicação expõe:
- `/health` — Health check
- `/ready` — Readiness probe
- `/metrics` — Métricas Prometheus

Configure no seu monitor favorito:
```yaml
# Prometheus scrape config
- job_name: 'kubenews'
  kubernetes_sd_configs:
  - role: pod
  relabel_configs:
  - source_labels: [__meta_kubernetes_pod_label_app]
    action: keep
    regex: kubenews
```

## 🐛 Troubleshooting

### Pipeline falha no push
```bash
# Verificar conexão com ACR
az acr login --name youracr
docker push youracr.azurecr.io/kubenews:latest
```

### Deployment stuck
```bash
# Verificar eventos
kubectl describe deployment kubenews

# Ver logs do pod
kubectl logs -f deployment/kubenews
```

### Imagem não encontrada
```bash
# Verificar se existe no ACR
az acr repository list --name youracr

# Verificar pull secret
kubectl get secrets -n default | grep acr
```

## 📝 Próximas Melhorias

- [ ] Adicionar testes automatizados
- [ ] Integração com SonarQube
- [ ] Notificações Slack
- [ ] Blue-Green deployment
- [ ] Canary deployment
- [ ] Backup automático do banco
- [ ] Disaster recovery plan
