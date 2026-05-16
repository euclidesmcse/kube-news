# ✅ Pipeline de CI/CD - Setup Checklist

## 📦 Arquivos Criados

```
kube-news/
├── 🐳 Dockerfile                    ← Imagem Docker multi-stage
├── 🐋 docker-compose.yml            ← Ambiente local (app + DB)
├── 📋 azure-pipelines.yml           ← Pipeline Azure DevOps
├── 📖 PIPELINE.md                   ← Guia detalhado
├── 📖 CI-CD-SETUP.md               ← Quick start
├── 📋 SETUP-CHECKLIST.md           ← Este arquivo
├── 🔧 scripts/
│   └── local-setup.sh              ← Script helper
├── ☸️  manifests/
│   ├── deployment.yml              ← Kubernetes deployment
│   └── service.yml                 ← Kubernetes service
└── .gitignore                       ← Atualizado
```

## 🚀 Fase 1: Testes Locais (Agora!)

✅ **Já feito:**
- Dockerfile criado e testado com sucesso ✓
- docker-compose.yml validado ✓
- Scripts criados ✓

**Próximo passo:**
```bash
./scripts/local-setup.sh up
```

### Checklist Local:
- [ ] Docker e Docker Compose instalados
- [ ] `./scripts/local-setup.sh up` executado com sucesso
- [ ] App respondendo em http://localhost:8080
- [ ] Endpoints testados: `/health`, `/ready`, `/metrics`
- [ ] `docker-compose down` para parar

## 🏢 Fase 2: Configuração Azure DevOps

**Pré-requisitos:**
- [ ] Conta no Azure DevOps
- [ ] Azure Container Registry (ACR) criado
- [ ] Azure Kubernetes Service (AKS) clusters criado (dev e prod)

**Passos:**

1. [ ] **Commit dos arquivos:**
   ```bash
   git add .
   git commit -m "feat: add CI/CD pipeline with Docker and Azure DevOps"
   git push
   ```

2. [ ] **Criar projeto no Azure DevOps** (se não existir)
   ```
   https://dev.azure.com/seu-org/seu-projeto
   ```

3. [ ] **Criar pipeline:**
   - Pipelines → Create pipeline
   - Selecione seu repositório
   - Existing Azure Pipelines YAML file
   - Selecione `azure-pipelines.yml`

4. [ ] **Configurar Service Connections:**
   - Project Settings → Service connections
   - Criar: Docker Registry (seu ACR)
   - Criar: Kubernetes (dev e prod clusters)

5. [ ] **Configurar variáveis do pipeline:**
   - Edit pipeline → Variables
   - `dockerRegistryServiceConnection` = seu-acr-connection
   - `containerRegistry` = youracr.azurecr.io

6. [ ] **Criar Environments:**
   - Pipelines → Environments
   - Create: "dev"
   - Create: "production"

## ☸️  Fase 3: Configuração Kubernetes

**Pré-requisitos:**
- [ ] kubectl instalado e configurado
- [ ] Acesso aos clusters dev e prod

**Passos:**

1. [ ] **Criar namespace (opcional, mas recomendado):**
   ```bash
   kubectl create namespace kubenews
   ```

2. [ ] **Criar Secret com credenciais do banco (dev):**
   ```bash
   kubectl create secret generic kubenews-secrets \
     --from-literal=db-host=seu-banco-dev.postgres.database.azure.com \
     --from-literal=db-port=5432 \
     --from-literal=db-database=kubedevnews \
     --from-literal=db-username=seu-usuario \
     --from-literal=db-password=sua-senha-segura \
     -n default
   ```

3. [ ] **Criar Secret (production):**
   ```bash
   kubectl create secret generic kubenews-secrets \
     --from-literal=db-host=seu-banco-prod.postgres.database.azure.com \
     --from-literal=db-port=5432 \
     --from-literal=db-database=kubedevnews \
     --from-literal=db-username=seu-usuario \
     --from-literal=db-password=sua-senha-segura \
     -n kubenews
   ```

4. [ ] **Ajustar manifests (se necessário):**
   - Editar `manifests/deployment.yml`:
     - Trocar `youracr.azurecr.io` pelo seu registry real
     - Ajustar replicas conforme necessário
     - Ajustar resource limits conforme sua infraestrutura

5. [ ] **Testar deploy local (opcional):**
   ```bash
   kubectl apply -f manifests/ --dry-run=client
   ```

## 🔐 Fase 4: Segurança

### Essencial:
- [ ] Secrets gerenciados pelo Azure Key Vault
- [ ] Container Registry scanning habilitado
- [ ] RBAC configurado no Kubernetes
- [ ] Network policies implementadas
- [ ] Liveness/Readiness probes testadas

### Checklist Segurança:
```bash
# Verificar Secret
kubectl get secrets kubenews-secrets -o yaml

# Verificar se container roda como non-root
kubectl exec -it deployment/kubenews -- id

# Verificar probes
kubectl describe deployment kubenews | grep -A 10 "Liveness\|Readiness"
```

## 📊 Fase 5: Monitoramento

- [ ] Prometheus scraping endpoints `/metrics`
- [ ] Alertas configurados para status não-saudável
- [ ] Logs centralizados (ELK, Application Insights, etc)
- [ ] Dashboard Grafana criado

## 🧪 Fase 6: Testes do Pipeline

### Primeiro Deploy:
1. [ ] Fazer push em branch `develop`
   ```bash
   git checkout -b test/ci-cd
   echo "test" >> README.md
   git commit -am "test: CI/CD pipeline trigger"
   git push origin test/ci-cd
   ```

2. [ ] Abrir Pull Request para `develop`
   - [ ] Verificar se pipeline foi acionado
   - [ ] Analisar logs de build
   - [ ] Aceitar o PR se tudo OK

3. [ ] Fazer merge para `develop`
   - [ ] Verificar deploy em Dev
   - [ ] Testar no Dev cluster

4. [ ] Fazer merge para `main`
   - [ ] Verificar deploy em Production
   - [ ] Fazer smoke tests

### Testes Recomendados:
```bash
# Verificar se aplicação está rodando
kubectl get pods -l app=kubenews

# Ver logs
kubectl logs -f deployment/kubenews

# Testar endpoint
kubectl port-forward svc/kubenews 8080:80
curl http://localhost:8080/health
```

## 📝 Documentação Relacionada

- **Quick Start:** [CI-CD-SETUP.md](CI-CD-SETUP.md)
- **Guia Detalhado:** [PIPELINE.md](PIPELINE.md)
- **Script Local:** `./scripts/local-setup.sh --help`

## 🆘 Troubleshooting Quick Reference

| Problema | Solução |
|----------|---------|
| Pipeline não triggered | Verificar webhook no Azure DevOps |
| Build falha | Ver logs em Pipelines → build |
| Deploy falha em K8s | Verificar Secret, resources, service connection |
| App não responde | Verificar logs: `kubectl logs deployment/kubenews` |
| Container não inicia | Verificar healthcheck: `docker logs container-id` |

## ✨ Status Geral

```
Fase 1 (Local): ✅ Completo
Fase 2 (Azure DevOps): ⏳ Aguardando você
Fase 3 (Kubernetes): ⏳ Aguardando você
Fase 4 (Segurança): ⏳ Aguardando configuração
Fase 5 (Monitoramento): ⏳ Aguardando você
Fase 6 (Testes): ⏳ Aguardando você
```

## 🎯 Próximos Passos Recomendados

1. **Agora:** Executar `./scripts/local-setup.sh up`
2. **Depois:** Configurar no Azure DevOps (veja Fase 2)
3. **Finalmente:** Deploy em produção (veja Fase 3+)

---

**💡 Dica:** Se tiver dúvidas em qualquer passo, consulte [PIPELINE.md](PIPELINE.md) para instruções detalhadas!

**Bom trabalho! 🚀**
