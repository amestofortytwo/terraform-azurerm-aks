<!-- BEGIN_TF_DOCS -->
# Azure Kubernetes Service

This is the repository for our Azure Kubernetes Service (AKS) Terraform module.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >3.21.1 |

## Examples

### Basic example

```hcl
module "kubernetes" {
  source  = "amestofortytwo/kubernetes"
  version = "1.2.0"

  name                = "demo-prod-westeu"
  resource_group_name = azurerm_resource_group.demo.name
  location            = azurerm_resource_group.demo.location

  tags = {
    environment = "production"
  }
}
```

### Advanced Example

```hcl
module "kubernetes" {
  source  = "amestofortytwo/kubernetes"
  version = "1.2.0"

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
```

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >3.21.1 |

## Modules

No modules.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aad_rbac"></a> [aad\_rbac](#input\_aad\_rbac) | (Optional) Used to fill the azure\_active\_directory\_role\_based\_access\_control block for the Kubernetes cluster.<br>  If nothing is specified, managed AAD RBAC will be enabled.<br><br>  If managed is set to true, the admin\_group\_object\_ids properties can be specified to a group that will have admin access to the cluster. | <pre>object({<br>    managed                = optional(bool)<br>    tenant_id              = optional(string)<br>    admin_group_object_ids = optional(list(string))<br>    azure_rbac_enabled     = optional(bool)<br>    client_app_id          = optional(string)<br>    server_app_id          = optional(string)<br>    server_app_secret      = optional(string)<br>  })</pre> | <pre>{<br>  "admin_group_object_ids": null,<br>  "azure_rbac_enabled": true,<br>  "managed": true<br>}</pre> | no |
| <a name="input_additional_node_pools"></a> [additional\_node\_pools](#input\_additional\_node\_pools) | (Optional) A list of additional node pools to add to the Kubernetes cluster.<br><br>  Each node pool can have the following properties:<br>  name - (Required) The name of the node pool.<br>  node\_count - (optional) The number of nodes in the node pool, defaults to 1.<br>  vm\_size - (optional) The size of the virtual machines to use for the node pool, defaults to the same as the default node pool. | <pre>list(object({<br>    name                 = string<br>    mode                 = optional(string)<br>    orchestrator_version = optional(string)<br>    os_type              = optional(string)<br>    os_sku               = optional(string)<br>    node_labels          = optional(map(string))<br>    node_count           = optional(number, 1)<br>    enable_auto_scaling  = optional(bool, false)<br>    min_count            = optional(number, 1)<br>    max_count            = optional(number, 3)<br>    vm_size              = optional(string)<br>    os_disk_size_gb      = optional(number)<br>    os_disk_type         = optional(string)<br>    vnet_subnet_id       = optional(string)<br>    max_pods             = optional(number)<br>    zones                = optional(list(string))<br>    scale_down_mode      = optional(string)<br>    ultra_ssd_enabled    = optional(bool)<br>    kubelet_disk_type    = optional(string)<br>    node_taints          = optional(list(string))<br>    tags                 = optional(map(string))<br>  }))</pre> | `[]` | no |
| <a name="input_api_server_authorized_ip_ranges"></a> [api\_server\_authorized\_ip\_ranges](#input\_api\_server\_authorized\_ip\_ranges) | (Optional) A list of authorized IP ranges to access the Kubernetes API server | `list(string)` | `null` | no |
| <a name="input_automatic_bump_kubernetes_version"></a> [automatic\_bump\_kubernetes\_version](#input\_automatic\_bump\_kubernetes\_version) | Automatically bump the Kubernetes version to the latest available version | <pre>object({<br>    enabled         = bool<br>    version_prefix  = string<br>    include_preview = bool<br>  })</pre> | <pre>{<br>  "enabled": false,<br>  "include_preview": false,<br>  "version_prefix": "1.23"<br>}</pre> | no |
| <a name="input_azure_policy_enabled"></a> [azure\_policy\_enabled](#input\_azure\_policy\_enabled) | Enable or disable Azure Policy for the cluster. Defaults to true. | `bool` | `true` | no |
| <a name="input_default_node_pool"></a> [default\_node\_pool](#input\_default\_node\_pool) | (Optional) The default node pool for the Kubernetes cluster.<br>  If not specified, the default node pool will have one Standard\_d2s\_v4 node. | <pre>object({<br>    name    = string<br>    vm_size = string<br><br>    # Autoscale or manual scaling<br>    node_count          = optional(number)<br>    enable_auto_scaling = optional(bool)<br>    autoscale = optional(object({<br>      min_count = number<br>      max_count = number<br>    }))<br><br>    # Optional settings<br>    max_pods                      = optional(number)<br>    capacity_reservation_group_id = optional(string)<br>    enable_host_encryption        = optional(bool)<br>    enable_node_public_ip         = optional(bool)<br>    fips_enabled                  = optional(bool)<br>    kubelet_disk_type             = optional(string)<br>    message_of_the_day            = optional(string)<br>    node_public_ip_prefix_id      = optional(string)<br>    node_labels                   = optional(map(string))<br>    only_critical_addons_enabled  = optional(bool)<br>    orchestrator_version          = optional(string)<br>    os_disk_size_gb               = optional(number)<br>    os_disk_type                  = optional(string)<br>    os_sku                        = optional(string)<br>    pod_subnet_id                 = optional(string)<br>    scale_down_mode               = optional(string)<br>    type                          = optional(string)<br>    tags                          = optional(map(string))<br>    ultra_ssd_enabled             = optional(bool)<br><br>    kubelet_config = optional(object(<br>      {<br>        cpu_manager_policy        = optional(string)<br>        cpu_cfs_quota_enabled     = optional(bool)<br>        cpu_cfs_quota_period      = optional(string)<br>        image_gc_high_threshold   = optional(number)<br>        image_gc_low_threshold    = optional(number)<br>        topology_manager_policy   = optional(string)<br>        allowed_unsafe_sysctls    = optional(list(string))<br>        container_log_max_size_mb = optional(number)<br>        container_log_max_line    = optional(number)<br>        pod_max_pid               = optional(number)<br>      }<br>    ))<br><br>    linux_os_config = optional(object({<br>      # sysctl will not be implemented, until someone needs it<br>      swap_file_size_mb             = optional(number)<br>      transparent_huge_page_enabled = optional(bool)<br>      transparent_huge_page_defrag  = optional(string)<br>    }))<br><br>    upgrade_settings = optional(object({<br>      max_surge = optional(number)<br>    }))<br>  })</pre> | <pre>{<br>  "name": "default",<br>  "node_count": 1,<br>  "vm_size": "Standard_D2s_v4"<br>}</pre> | no |
| <a name="input_identity"></a> [identity](#input\_identity) | (Optional) The identity block for the Kubernetes cluster.<br>  If not specified, the identity will be of type SystemAssigned. | <pre>object({<br>    type         = string<br>    identity_ids = optional(list(string))<br>  })</pre> | <pre>{<br>  "identity_ids": null,<br>  "type": "SystemAssigned"<br>}</pre> | no |
| <a name="input_ingress_application_gateway"></a> [ingress\_application\_gateway](#input\_ingress\_application\_gateway) | Values used for deployment of the ingress application gateway | <pre>object({<br>    gateway_id   = optional(string)<br>    gateway_name = optional(string)<br>    subnet_cidr  = optional(string)<br>    subnet_id    = optional(string)<br>  })</pre> | `null` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Kubernetes version to use for the cluster | `string` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | The location where all resources will be created | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the managed Kubernetes cluster.<br><br>  Will prefix the name of the cluster with `aks-`. | `string` | n/a | yes |
| <a name="input_network_profile"></a> [network\_profile](#input\_network\_profile) | (Optional) The network profile block for the Kubernetes cluster.<br>  If not specified, the network profile will be of type Azure. | <pre>object({<br>    network_plugin     = string<br>    network_policy     = optional(string)<br>    network_mode       = optional(string)<br>    vnet_subnet_id     = optional(string)<br>    load_balancer_sku  = optional(string)<br>    outbound_type      = optional(string)<br>    dns_service_ip     = optional(string)<br>    docker_bridge_cidr = optional(string)<br>    service_cidr       = optional(string)<br>    service_cidrs      = optional(list(string))<br>    pod_cidr           = optional(string)<br>    pod_cidrs          = optional(list(string))<br>    ip_versions        = optional(list(string))<br>  })</pre> | <pre>{<br>  "network_plugin": "azure"<br>}</pre> | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group to create the resources in | `string` | n/a | yes |
| <a name="input_service_principal"></a> [service\_principal](#input\_service\_principal) | (Optional) The service principal block for the Kubernetes cluster.<br>  Do not specify this block if you want already defined the identity block, or if you want to use the SystemAssigned identity. | <pre>object({<br>    client_id     = string<br>    client_secret = string<br>  })</pre> | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the resources | `map(string)` | n/a | yes |
| <a name="input_workload_identity_enabled"></a> [workload\_identity\_enabled](#input\_workload\_identity\_enabled) | (Optional) Enable or disable workload identity for the cluster. Enabling this also sets oidc\_issuer\_enabled to true. | `bool` | `null` | no |

## Outputs

No outputs.

## Resources

| Name | Type |
|------|------|
| [azurerm_kubernetes_cluster.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster) | resource |
| [azurerm_kubernetes_cluster_node_pool.additional](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_node_pool) | resource |
| [azurerm_kubernetes_service_versions.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/kubernetes_service_versions) | data source |
<!-- END_TF_DOCS -->