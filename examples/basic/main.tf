#trivy:ignore:avd-azu-0041
module "kubernetes" {
  source  = "fortytwoservices/aks/azurerm"
  version = "3.5.0"

  name                = "demo-prod-westeu"
  resource_group_name = azurerm_resource_group.demo.name
  location            = azurerm_resource_group.demo.location

  tags = {
    environment = "production"
  }
}
