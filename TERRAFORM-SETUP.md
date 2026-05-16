# ⚡ Setup Rápido - Infrastructure as Code

## 3 Passos para Provisionar Tudo Automaticamente

### Passo 1️⃣: Criar Storage Account para Estado Terraform

Execute uma única vez:

```bash
# Faça login no Azure
az login

# Crie o storage account
az group create --name rg-terraform-state --location eastus

az storage account create \
  --name kubenewstfstate \
  --resource-group rg-terraform-state \
  --location eastus \
  --sku Standard_LRS

az storage container create \
  --name tfstate \
  --account-name kubenewstfstate
```

### Passo 2️⃣: Configurar Service Connection no Azure DevOps

1. Vá em **Azure DevOps** → Seu projeto **Pipelines**
2. **Project Settings** → **Service connections**
3. **New service connection** → **Azure Resource Manager**
4. **Service principal (automatic)** 
5. Selecione sua subscription e clique **Save**
6. **Renomeie** para: `azure-subscription-connection`

### Passo 3️⃣: Atualizar Pipeline e Fazer Commit

```bash
# Customize as variáveis do Terraform
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
# Edite terraform/terraform.tfvars se necessário

# Atualize o pipeline para usar Terraform
cp azure-pipelines-full.yml azure-pipelines.yml

# Commit tudo
git add .
git commit -m "feat: IaC with Terraform for Azure infrastructure"
git push
```

## ✨ Pronto!

Agora quando você fizer push para `main`:

1. ✅ Terraform provisiona **Resource Group**
2. ✅ Terraform provisiona **Azure Container Registry**
3. ✅ Terraform provisiona **AKS Dev cluster** (1 nó)
4. ✅ Terraform provisiona **AKS Prod cluster** (3 nós)
5. ✅ Docker build e push
6. ✅ Deploy em produção

**Tudo automaticamente! 🚀**

## 📊 Monitorar

```bash
# Ver clusters criados
az aks list --output table

# Ver container registry
az acr list --output table

# Conectar ao cluster
az aks get-credentials --resource-group rg-kubenews --name aks-kubenews-dev
kubectl get nodes
```

## 💡 Dicas

- **terraform.tfvars** não é commitado (tem valores reais)
- **Mudança na infraestrutura?** Edite Terraform e faça push
- **Destruir tudo?** No pipeline, mude `command: 'apply'` para `command: 'destroy'`

---

**Agora tudo funciona sem intervenção manual! 🎉**
