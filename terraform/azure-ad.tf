# Service Principal para AKS
resource "azuread_application" "aks" {
  display_name = "${var.project_name}-aks-sp"
}

resource "azuread_service_principal" "aks" {
  client_id = azuread_application.aks.client_id

  tags = ["AKS"]
}

resource "azuread_service_principal_password" "aks" {
  service_principal_id = azuread_service_principal.aks.id
  end_date_relative   = "8760h" # 1 ano
}

# Role Assignment - Contributor no Resource Group para o Service Principal
resource "azurerm_role_assignment" "aks_rg_contributor" {
  scope              = azurerm_resource_group.rg.id
  role_definition_name = "Contributor"
  principal_id       = azuread_service_principal.aks.object_id
}
