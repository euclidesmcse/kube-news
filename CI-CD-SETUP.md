# 🚀 Pipeline de CI/CD - Kube-News

Seu pipeline de CI/CD foi criado com sucesso! Aqui está o resumo completo.

## 📦 Arquivos Criados

### Configuração Docker
- **Dockerfile** — Imagem Docker otimizada com multi-stage build
- **docker-compose.yml** — Ambiente local completo (app + PostgreSQL)

### Pipeline e Automação
- **azure-pipelines.yml** — Pipeline completo de CI/CD para Azure DevOps
- **scripts/local-setup.sh** — Script helper para desenvolvimento local

### Kubernetes
- **manifests/deployment.yml** — Deployment com health checks e best practices
- **manifests/service.yml** — Service para expor a aplicação

### Documentação
- **PIPELINE.md** — Guia detalhado de configuração e uso
- **CI-CD-SETUP.md** — Este arquivo (instruções rápidas)

## ⚡ Quick Start

### 1️⃣ Testar Localmente (sem Kubernetes)

```bash
# Iniciar ambiente
./scripts/local-setup.sh up

# Testar endpoints
./scripts/local-setup.sh test

# Ver logs
./scripts/local-setup.sh logs

# Parar ambiente
./scripts/local-setup.sh down
```

A aplicação estará disponível em: **http://localhost:8080**

### 2️⃣ Preparar Azure DevOps

1. **Commit dos arquivos:**
   ```bash
   git add Dockerfile docker-compose.yml azure-pipelines.yml manifests/ scripts/
   git commit -m "feat: adicionar pipeline CI/CD com Azure DevOps"
   git push
   ```

2. **No Azure DevOps:**
   - Vá em **Pipelines** → **Create pipeline**
   - Selecione seu repositório
   - Escolha **Existing Azure Pipelines YAML file**
   - Selecione `azure-pipelines.yml`

3. **Configure as variáveis do pipeline:**
   Edit pipeline → Variables
   ```
   dockerRegistryServiceConnection = seu-acr-connection
   containerRegistry = youracr.azurecr.io
   ```

4. **Configure os Secrets no Kubernetes:**
   ```bash
   kubectl create secret generic kubenews-secrets \
     --from-literal=db-host=seu-banco.postgres.database.azure.com \
     --from-literal=db-port=5432 \
     --from-literal=db-database=kubedevnews \
     --from-literal=db-username=seu-usuario \
     --from-literal=db-password=sua-senha
   ```

## 📊 Fluxo do Pipeline

```
Push em main/develop
    ↓
1. BUILD STAGE
   - Node.js setup
   - npm install
   - Docker build
   - Push to Azure Container Registry
    ↓
2. SECURITY STAGE (opcional)
   - Trivy vulnerability scan
    ↓
3. DEPLOY STAGE
   - develop → Deploy em Dev
   - main → Deploy em Prod
   - Rolling update strategy
```

## 🔑 Características Implementadas

✅ **Build:**
- Node.js 18 Alpine (imagem pequena)
- Multi-stage Docker
- Cache optimization

✅ **Segurança:**
- Container roda como non-root
- Read-only root filesystem
- Resource limits (CPU/Memory)
- Capacidades Linux removidas

✅ **Kubernetes:**
- 3 replicas com Rolling Update
- Liveness probe (/health)
- Readiness probe (/ready)
- Pod anti-affinity
- Secrets para dados sensíveis

✅ **CI/CD:**
- Trigger automático em push
- Build isolados por branch
- Ambientes separados (dev/prod)
- Push to ACR automático

## 📋 Próximas Etapas

### Essencial (antes de produção)
- [ ] Verificar/ajustar imagem base Node.js (versão 18)
- [ ] Configurar Azure Container Registry
- [ ] Configurar AKS clusters (dev/prod)
- [ ] Criar secrets no Kubernetes
- [ ] Testar pipeline no Azure DevOps

### Recomendado
- [ ] Adicionar testes automatizados (pytest, jest)
- [ ] Integração com SonarQube
- [ ] Configurar notificações Slack
- [ ] Backup automático do banco
- [ ] Monitoring com Prometheus/Grafana

### Nice-to-have
- [ ] Blue-Green deployment
- [ ] Canary deployment
- [ ] ArgoCD para GitOps
- [ ] Sealed Secrets para dados sensíveis
- [ ] Network Policies

## 🐛 Troubleshooting

### Pipeline não funciona no Azure DevOps?
1. Verifique se a conexão com ACR está configurada
2. Verifique se os environments (dev/prod) existem
3. Verifique os logs do pipeline

### Container não sobe?
```bash
# Ver logs
docker-compose logs kubenews

# Verificar saúde
curl http://localhost:8080/health
```

### Erro ao fazer deploy em Kubernetes?
```bash
# Verificar secret
kubectl get secrets kubenews-secrets

# Ver eventos
kubectl describe pod -l app=kubenews

# Ver logs do pod
kubectl logs -l app=kubenews
```

## 📞 Próximos Passos

1. **Testar localmente:**
   ```bash
   ./scripts/local-setup.sh up
   ./scripts/local-setup.sh test
   ```

2. **Fazer commit:**
   ```bash
   git add .
   git commit -m "feat: CI/CD pipeline com Docker e Azure DevOps"
   git push
   ```

3. **Configurar no Azure DevOps** (veja PIPELINE.md para detalhes)

4. **Monitorar primeira execução:**
   - Vá em Pipelines → Ver execução
   - Analise logs se houver erros
   - Ajuste variáveis conforme necessário

## 📚 Documentação Completa

Para instruções detalhadas de configuração, troubleshooting e boas práticas, veja:
**[PIPELINE.md](PIPELINE.md)**

---

✨ Seu pipeline está pronto para ser utilizado!
