# 🏗️ Infrastructure as Code com Terraform

Seu pipeline agora provisiona **toda a infraestrutura automaticamente**!

## 📦 O que é Provisionado

```
Azure Infrastructure
├── Resource Group (rg-kubenews)
├── Azure Container Registry (ACR)
│   └── Para armazenar imagens Docker
├── AKS Cluster DEV
│   ├── 1 nó
│   └── Zona 1 e 2
├── AKS Cluster PROD
│   ├── 3 nós
│   └── Zona 1, 2 e 3
└── Service Principal
    └── Para autenticação entre serviços
```

## 🚀 Setup Inicial (Uma Única Vez)

### 1️⃣ Criar Storage Account para Estado Terraform

```bash
# Variáveis
RESOURCE_GROUP="rg-terraform-state"
STORAGE_ACCOUNT="kubenewstfstate"
CONTAINER_NAME="tfstate"

# Criar resource group
az group create \
  --name $RESOURCE_GROUP \
  --location eastus

# Criar storage account
az storage account create \
  --name $STORAGE_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --location eastus \
  --sku Standard_LRS

# Criar container
az storage container create \
  --name $CONTAINER_NAME \
  --account-name $STORAGE_ACCOUNT
```

### 2️⃣ Configurar Service Connection no Azure DevOps

1. **Azure DevOps** → **Project Settings** → **Service connections**
2. **New service connection** → **Azure Resource Manager**
3. Selecione **Service principal (automatic)**
4. Configure sua subscription
5. **Name:** `azure-subscription-connection`
6. **Save**

### 3️⃣ Atualizar Pipeline

Seu `azure-pipelines.yml` já está pronto com Terraform! 

Arquivo novo: `azure-pipelines-full.yml` (use este no pipeline)

## 📝 Customizar Variáveis

1. Copie o arquivo de exemplo:
   ```bash
   cp terraform/terraform.tfvars.example terraform/terraform.tfvars
   ```

2. Edite `terraform/terraform.tfvars`:
   ```hcl
   project_name       = "kubenews"      # Seu nome
   location           = "eastus"        # Sua região
   aks_dev_node_count = 1               # Nós em Dev
   aks_prod_node_count = 3              # Nós em Prod
   aks_vm_size        = "Standard_B2s"  # Tamanho das VMs
   ```

## 🔄 Fluxo Automático

```
Push para main
    ↓
STAGE 1: Provision Infrastructure
├─ Terraform Init
├─ Terraform Plan
├─ Terraform Apply
└─ Configure kubectl
    ↓
STAGE 2: Build Docker Image
├─ npm install
├─ Docker build
└─ Push to ACR
    ↓
STAGE 3: Security Scan
└─ Trivy vulnerability scan
    ↓
STAGE 4: Deploy Production
└─ Apply manifests em AKS
```

## 📊 Monitorar Infraestrutura

### Ver Recursos Criados

```bash
# Resource Groups
az group list --output table

# Container Registry
az acr list --output table

# AKS Clusters
az aks list --output table

# Ver kubeconfigs
kubectl config get-contexts
```

### Conectar aos Clusters

```bash
# Dev
az aks get-credentials \
  --resource-group rg-kubenews \
  --name aks-kubenews-dev

# Prod
az aks get-credentials \
  --resource-group rg-kubenews \
  --name aks-kubenews-prod

# Listar contextos
kubectl config get-contexts
```

## 🔐 Segurança

O Terraform cria automaticamente:
- ✅ Service Principal com permissões mínimas
- ✅ Role Assignments para AKS acessar ACR
- ✅ Network Policies habilitadas
- ✅ Azure AD integrado

## 💰 Custos

**Estimativa mensal (pequena escala):**
- ACR Basic: ~$5
- AKS (3 B2s nodes): ~$100-150
- Storage (Terraform state): <$1

**Para reduzir custos:**
- Reduzir `aks_prod_node_count` para 1
- Usar `Standard_B1s` em vez de `B2s`

## 🐛 Troubleshooting

### Terraform falha com "Permission denied"

```bash
# Verifique se está logado
az account show

# Trocar subscription se tiver múltiplas
az account set --subscription "seu-subscription-id"
```

### Estado Terraform corrompido

```bash
# Fazer backup
az storage blob download \
  --account-name kubenewstfstate \
  --container-name tfstate \
  --name kubenews.tfstate \
  --file kubenews.tfstate.bak

# Remover e recriar
az storage blob delete \
  --account-name kubenewstfstate \
  --container-name tfstate \
  --name kubenews.tfstate

# Re-apply
# (execute novamente o pipeline)
```

### AKS não consegue acessar ACR

```bash
# Verifique role assignments
az role assignment list \
  --scope /subscriptions/seu-subscription-id/resourceGroups/rg-kubenews \
  --output table
```

## 📚 Estrutura Terraform

```
terraform/
├── main.tf              # Recursos principais (RG, ACR, AKS)
├── azure-ad.tf         # Service Principal
├── variables.tf        # Declaração de variáveis
├── outputs.tf          # Saídas importantes
└── terraform.tfvars    # Valores das variáveis (não commitado)
```

## 🔄 Atualizar Infraestrutura

Quando precisar mudar algo:

1. Edite `terraform/` ou `terraform.tfvars`
2. Faça commit
3. Push para `main`
4. Pipeline roda `terraform plan` → `terraform apply`

Exemplo: aumentar nós em produção
```hcl
# terraform.tfvars
aks_prod_node_count = 5  # Era 3, agora 5

# Commit e push
git add terraform/terraform.tfvars
git commit -m "chore: scale prod cluster to 5 nodes"
git push
```

## ✨ Próximos Passos

1. **Criar o Storage Account** para Terraform state
2. **Configurar Service Connection** no Azure DevOps
3. **Customizar terraform.tfvars**
4. **Atualizar pipeline:** use `azure-pipelines-full.yml`
5. **Fazer commit**
6. **Monitorar primeira execução**

---

**Com isso, toda sua infraestrutura é código, versionada no Git e provisionada automaticamente! 🚀**
