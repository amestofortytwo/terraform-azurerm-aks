#trivy:ignore:avd-azu-0041
module "kubernetes" {
  source  = "fortytwoservices/aks/azurerm"
  version = "3.5.0"

  name                = "demo-prod-westeu"
  resource_group_name = azurerm_resource_group.demo.name
  location            = azurerm_resource_group.demo.location

  service_principal = {
    client_id     = "00000000-0000-0000-0000-000000000000"
    client_secret = "client_secret_value"
  }

  automatic_bump_kubernetes_version = {
    enabled         = true
    version_prefix  = "1.23"
    include_preview = false
  }

  additional_node_pools = [
    { name = "pool1" },
    { name = "pool2" }
  ]

  tags = {
    environment = "production"
  }
}
