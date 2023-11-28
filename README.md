<!-- BEGIN_TF_DOCS -->
# Azure Kubernetes Service

This is the repository for our Azure Kubernetes Service (AKS) Terraform module.

## Requirements

The following requirements are needed by this module:

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (>3.63.0)

## Examples

### Basic example

```hcl
module "kubernetes" {
  source  = "amestofortytwo/aks/azurerm"
  version = "3.0.0"

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
  source  = "amestofortytwo/aks/azurerm"
  version = "3.0.0"

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

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (>3.63.0)

## Modules

No modules.

## Required Inputs

The following input variables are required:

### <a name="input_location"></a> [location](#input\_location)

Description: The location where all resources will be created

Type: `string`

### <a name="input_name"></a> [name](#input\_name)

Description: The name of the managed Kubernetes cluster.

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: Name of the resource group to create the resources in

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_aad_rbac"></a> [aad\_rbac](#input\_aad\_rbac)

Description:   (Optional) Used to fill the azure\_active\_directory\_role\_based\_access\_control block for the Kubernetes cluster.  
  If nothing is specified, managed AAD RBAC will be enabled.

  If managed is set to true, the admin\_group\_object\_ids properties can be specified to a group that will have admin access to the cluster.

Type:

```hcl
object({
    managed                = optional(bool)
    tenant_id              = optional(string)
    admin_group_object_ids = optional(list(string))
    azure_rbac_enabled     = optional(bool)
    client_app_id          = optional(string)
    server_app_id          = optional(string)
    server_app_secret      = optional(string)
  })
```

Default:

```json
{
  "admin_group_object_ids": null,
  "azure_rbac_enabled": true,
  "managed": true
}
```

### <a name="input_additional_node_pools"></a> [additional\_node\_pools](#input\_additional\_node\_pools)

Description:   (Optional) A list of additional node pools to add to the Kubernetes cluster.

  Each node pool can have the following properties:  
  name - (Required) The name of the node pool.  
  node\_count - (optional) The number of nodes in the node pool, defaults to 1.  
  vm\_size - (optional) The size of the virtual machines to use for the node pool, defaults to the same as the default node pool.

Type:

```hcl
list(object({
    name                 = string
    mode                 = optional(string)
    orchestrator_version = optional(string)
    os_type              = optional(string)
    os_sku               = optional(string)
    node_labels          = optional(map(string))
    node_count           = optional(number)
    enable_auto_scaling  = optional(bool, false)
    min_count            = optional(number)
    max_count            = optional(number)
    vm_size              = optional(string)
    os_disk_size_gb      = optional(number)
    os_disk_type         = optional(string)
    vnet_subnet_id       = optional(string)
    pod_subnet_id        = optional(string)
    max_pods             = optional(number)
    zones                = optional(list(string))
    scale_down_mode      = optional(string)
    ultra_ssd_enabled    = optional(bool)
    kubelet_disk_type    = optional(string)
    node_taints          = optional(list(string))
    tags                 = optional(map(string))
    priority             = optional(string)
    spot_max_price       = optional(string)
    eviction_policy      = optional(string)

    linux_os_config = optional(object({
      swap_file_size_mb             = optional(number)
      transparent_huge_page_enabled = optional(bool)
      transparent_huge_page_defrag  = optional(string)

      sysctl_config = optional(object({
        vm_max_map_count = optional(number)
      }))
    }))
  }))
```

Default: `[]`

### <a name="input_api_server_authorized_ip_ranges"></a> [api\_server\_authorized\_ip\_ranges](#input\_api\_server\_authorized\_ip\_ranges)

Description: (Optional) A list of authorized IP ranges to access the Kubernetes API server

Type: `list(string)`

Default: `null`

### <a name="input_auto_scaler_profile"></a> [auto\_scaler\_profile](#input\_auto\_scaler\_profile)

Description: The auto scaler profile for the Kubernetes cluster.

Type:

```hcl
object({
    balance_similar_node_groups      = optional(bool)
    expander                         = optional(string)
    max_graceful_termination_sec     = optional(number)
    max_node_provisioning_time       = optional(string)
    max_unready_nodes                = optional(number)
    new_pod_scale_up_delay           = optional(string)
    scale_down_delay_after_add       = optional(string)
    scale_down_delay_after_delete    = optional(string)
    scale_down_delay_after_failure   = optional(string)
    scale_down_unneeded              = optional(string)
    scale_down_unready               = optional(string)
    scale_down_utilization_threshold = optional(string)
    empty_bulk_delete_max            = optional(number)
    skip_nodes_with_local_storage    = optional(bool)
    skip_nodes_with_system_pods      = optional(bool)
  })
```

Default: `null`

### <a name="input_automatic_bump_kubernetes_version"></a> [automatic\_bump\_kubernetes\_version](#input\_automatic\_bump\_kubernetes\_version)

Description: Automatically bump the Kubernetes version to the latest available version

Type:

```hcl
object({
    enabled         = bool
    version_prefix  = string
    include_preview = bool
  })
```

Default:

```json
{
  "enabled": false,
  "include_preview": false,
  "version_prefix": "1.23"
}
```

### <a name="input_automatic_channel_upgrade"></a> [automatic\_channel\_upgrade](#input\_automatic\_channel\_upgrade)

Description: (Optional) The upgrade channel for this Kubernetes Cluster. Possible values are patch, rapid, node-image and stable. Omitting this field sets this value to none.

Type: `string`

Default: `"none"`

### <a name="input_azure_monitor"></a> [azure\_monitor](#input\_azure\_monitor)

Description:   (Optional) Enable or disable Azure Monitor for the cluster. Defaults to true.  
  If neither azure\_monitor.log\_analytics\_workspace\_id nor default\_log\_analytics\_workspace\_id is specified, a new Log Analytics Workspace will be created with the same name as the AKS cluster and in the same resource group.

Type:

```hcl
object({
    enabled                    = optional(bool, true)
    log_analytics_workspace_id = optional(string, null)
  })
```

Default:

```json
{
  "enabled": true,
  "log_analytics_workspace_id": null
}
```

### <a name="input_azure_policy_enabled"></a> [azure\_policy\_enabled](#input\_azure\_policy\_enabled)

Description: Enable or disable Azure Policy for the cluster. Defaults to true.

Type: `bool`

Default: `true`

### <a name="input_default_log_analytics_workspace_id"></a> [default\_log\_analytics\_workspace\_id](#input\_default\_log\_analytics\_workspace\_id)

Description:   (Optional) The id of the Log Analytics Workspace to use as default for Defender and Azure Monitor.  
  Each of these services can be configured to use a different Log Analytics Workspace, which will override this setting.  
  If neither this nor the service spesific variable is specified, and the services are enabled, a new Log Analytics Workspace will be created.

Type: `string`

Default: `null`

### <a name="input_default_node_pool"></a> [default\_node\_pool](#input\_default\_node\_pool)

Description:   (Optional) The default node pool for the Kubernetes cluster.  
  If not specified, the default node pool will have one Standard\_d2s\_v4 node.

Type:

```hcl
object({
    name    = string
    vm_size = string

    # Autoscale or manual scaling
    node_count          = optional(number)
    enable_auto_scaling = optional(bool)
    autoscale = optional(object({
      min_count = number
      max_count = number
    }))

    # Optional settings
    max_pods                      = optional(number)
    capacity_reservation_group_id = optional(string)
    enable_host_encryption        = optional(bool)
    enable_node_public_ip         = optional(bool)
    fips_enabled                  = optional(bool)
    kubelet_disk_type             = optional(string)
    message_of_the_day            = optional(string)
    node_public_ip_prefix_id      = optional(string)
    node_labels                   = optional(map(string))
    node_taints                   = optional(list(string))
    only_critical_addons_enabled  = optional(bool)
    orchestrator_version          = optional(string)
    os_disk_size_gb               = optional(number)
    os_disk_type                  = optional(string)
    os_sku                        = optional(string)
    pod_subnet_id                 = optional(string)
    scale_down_mode               = optional(string)
    type                          = optional(string)
    tags                          = optional(map(string))
    ultra_ssd_enabled             = optional(bool)

    kubelet_config = optional(object(
      {
        cpu_manager_policy        = optional(string)
        cpu_cfs_quota_enabled     = optional(bool)
        cpu_cfs_quota_period      = optional(string)
        image_gc_high_threshold   = optional(number)
        image_gc_low_threshold    = optional(number)
        topology_manager_policy   = optional(string)
        allowed_unsafe_sysctls    = optional(list(string))
        container_log_max_size_mb = optional(number)
        container_log_max_line    = optional(number)
        pod_max_pid               = optional(number)
      }
    ))

    linux_os_config = optional(object({
      # sysctl will not be implemented, until someone needs it
      swap_file_size_mb             = optional(number)
      transparent_huge_page_enabled = optional(bool)
      transparent_huge_page_defrag  = optional(string)
    }))

    upgrade_settings = optional(object({
      max_surge = optional(number)
    }))
  })
```

Default:

```json
{
  "name": "default",
  "node_count": 1,
  "vm_size": "Standard_D2s_v4"
}
```

### <a name="input_disable_telemetry"></a> [disable\_telemetry](#input\_disable\_telemetry)

Description: If set to true, will disable telemetry for the module.

Type: `bool`

Default: `false`

### <a name="input_disk_encryption_set_id"></a> [disk\_encryption\_set\_id](#input\_disk\_encryption\_set\_id)

Description: (Optional) The ID of the Disk Encryption Set which should be used for the Nodes and Volumes. More information [can be found in the documentation](https://docs.microsoft.com/azure/aks/azure-disk-customer-managed-keys). Changing this forces a new resource to be created.

Type: `string`

Default: `null`

### <a name="input_identity"></a> [identity](#input\_identity)

Description:   (Optional) The identity block for the Kubernetes cluster.  
  If not specified, the identity will be of type SystemAssigned.

Type:

```hcl
object({
    type         = string
    identity_ids = optional(list(string))
  })
```

Default:

```json
{
  "identity_ids": null,
  "type": "SystemAssigned"
}
```

### <a name="input_ingress_application_gateway"></a> [ingress\_application\_gateway](#input\_ingress\_application\_gateway)

Description: Values used for deployment of the ingress application gateway

Type:

```hcl
object({
    gateway_id   = optional(string)
    gateway_name = optional(string)
    subnet_cidr  = optional(string)
    subnet_id    = optional(string)
  })
```

Default: `null`

### <a name="input_key_vault_secrets_provider"></a> [key\_vault\_secrets\_provider](#input\_key\_vault\_secrets\_provider)

Description: (Optional) Enable or disable Azure Key Vault Secret Providers for the cluster. Defaults to false.

Type:

```hcl
object({
    enabled                  = optional(bool, false)
    secret_rotation_enabled  = optional(bool, false)
    secret_rotation_interval = optional(string, null)
  })
```

Default: `{}`

### <a name="input_kms_enabled"></a> [kms\_enabled](#input\_kms\_enabled)

Description: (Optional) Enable Azure Key Vault Key Management Service.

Type: `bool`

Default: `false`

### <a name="input_kms_key_vault_key_id"></a> [kms\_key\_vault\_key\_id](#input\_kms\_key\_vault\_key\_id)

Description: (Optional) Identifier of Azure Key Vault key. When Azure Key Vault key management service is enabled, this field is required and must be a valid key identifier.

Type: `string`

Default: `null`

### <a name="input_kms_key_vault_network_access"></a> [kms\_key\_vault\_network\_access](#input\_kms\_key\_vault\_network\_access)

Description: (Optional) Network Access of Azure Key Vault. Possible values are: 'Private' and 'Public'. The default value is 'Private'.

Type: `string`

Default: `"Private"`

### <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version)

Description: Kubernetes version to use for the cluster

Type: `string`

Default: `null`

### <a name="input_local_account_disabled"></a> [local\_account\_disabled](#input\_local\_account\_disabled)

Description: (Optional) Enable or disable local account for the cluster. Defaults to true.

Type: `bool`

Default: `true`

### <a name="input_microsoft_defender"></a> [microsoft\_defender](#input\_microsoft\_defender)

Description:   (Optional) Enable or disable Microsoft Defender (Security profile) for the cluster. Defaults to false.  
  If neither microsoft\_defender.log\_analytics\_workspace\_id nor default\_log\_analytics\_workspace\_id is specified, a new Log Analytics Workspace will be created with the same name as the AKS cluster and in the same resource group.

Type:

```hcl
object({
    enabled                    = optional(bool, false)
    log_analytics_workspace_id = optional(string, null)
  })
```

Default:

```json
{
  "enabled": false,
  "log_analytics_workspace_id": null
}
```

### <a name="input_network_profile"></a> [network\_profile](#input\_network\_profile)

Description:   (Optional) The network profile block for the Kubernetes cluster.  
  If not specified, the network profile will be of type Azure.

Type:

```hcl
object({
    network_plugin      = string
    network_plugin_mode = optional(string)
    network_policy      = optional(string)
    network_mode        = optional(string)
    vnet_subnet_id      = optional(string)
    load_balancer_sku   = optional(string)
    outbound_type       = optional(string)
    dns_service_ip      = optional(string)
    docker_bridge_cidr  = optional(string)
    service_cidr        = optional(string)
    service_cidrs       = optional(list(string))
    pod_cidr            = optional(string)
    pod_cidrs           = optional(list(string))
    ip_versions         = optional(list(string))
    ebpf_data_plane     = optional(string)
  })
```

Default:

```json
{
  "network_plugin": "azure"
}
```

### <a name="input_private_cluster"></a> [private\_cluster](#input\_private\_cluster)

Description: (Optional) Enable or disable private cluster for the cluster. Defaults to false.

Type: `bool`

Default: `false`

### <a name="input_service_principal"></a> [service\_principal](#input\_service\_principal)

Description:   (Optional) The service principal block for the Kubernetes cluster.  
  Do not specify this block if you want already defined the identity block, or if you want to use the SystemAssigned identity.

Type:

```hcl
object({
    client_id     = string
    client_secret = string
  })
```

Default: `null`

### <a name="input_sku_tier"></a> [sku\_tier](#input\_sku\_tier)

Description: (Optional) The SKU Tier that should be used for this Kubernetes Cluster. Possible values are Free, and Standard (which includes the Uptime SLA). Defaults to Free.

Type: `string`

Default: `"Free"`

### <a name="input_storage_profile"></a> [storage\_profile](#input\_storage\_profile)

Description: (Optional) The storage profile block for the Kubernetes cluster.

Type:

```hcl
object({
    blob_driver_enabled         = optional(bool)
    disk_driver_enabled         = optional(bool)
    disk_driver_version         = optional(string)
    file_driver_enabled         = optional(bool)
    snapshot_controller_enabled = optional(bool)
  })
```

Default: `null`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: (Optional) A mapping of tags to assign to the resources

Type: `map(string)`

Default: `{}`

### <a name="input_workload_identity_enabled"></a> [workload\_identity\_enabled](#input\_workload\_identity\_enabled)

Description: (Optional) Enable or disable workload identity for the cluster. Enabling this also sets oidc\_issuer\_enabled to true.

Type: `bool`

Default: `null`

## Outputs

The following outputs are exported:

### <a name="output_aks_credentials"></a> [aks\_credentials](#output\_aks\_credentials)

Description: The AZ CLI command to get credentials from your new cluster.

### <a name="output_aks_id"></a> [aks\_id](#output\_aks\_id)

Description: The Kubernetes Managed Cluster ID.

### <a name="output_client_certificate"></a> [client\_certificate](#output\_client\_certificate)

Description: Base64 encoded public certificate used by clients to authenticate to the Kubernetes cluster.

### <a name="output_client_key"></a> [client\_key](#output\_client\_key)

Description: Base64 encoded private key used by clients to authenticate to the Kubernetes cluster.

### <a name="output_cluster_ca_certificate"></a> [cluster\_ca\_certificate](#output\_cluster\_ca\_certificate)

Description: Base64 encoded public CA certificate used as the root of trust for the Kubernetes cluster.

### <a name="output_host"></a> [host](#output\_host)

Description: The Kubernetes cluster server host.

### <a name="output_identity"></a> [identity](#output\_identity)

Description: Block of the parameters from the Managed Service Identity.

### <a name="output_kube_admin_config_raw"></a> [kube\_admin\_config\_raw](#output\_kube\_admin\_config\_raw)

Description: The raw kube admin config, used with kubectl and other tools.

### <a name="output_kubelet_identity"></a> [kubelet\_identity](#output\_kubelet\_identity)

Description: The raw kubelet identity. Used for Azure role assignments.

### <a name="output_oidc_issuer_url"></a> [oidc\_issuer\_url](#output\_oidc\_issuer\_url)

Description: The OIDC issuer URL that is associated with the cluster.

### <a name="output_secret_identity"></a> [secret\_identity](#output\_secret\_identity)

Description: Block of the parameters from the Key Vault Secrets Provider.

## Resources

The following resources are used by this module:

- [azurerm_kubernetes_cluster.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster) (resource)
- [azurerm_kubernetes_cluster_node_pool.additional](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_node_pool) (resource)
- [azurerm_log_analytics_workspace.main](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) (resource)
- [azurerm_subscription_template_deployment.telemetry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subscription_template_deployment) (resource)
- [azurerm_kubernetes_service_versions.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/kubernetes_service_versions) (data source)

## Telemetry

> **NOTE:** The following statement is applicable from release v3.2.0 onwards

When you deploy this template, Microsoft can identify the installation of Amesto Fortytwo software with the deployed Azure resources.
Microsoft can correlate these resources used to support the software. Microsoft collects this information to provide the best experiences with their products and to operate their business. The data is collected and governed by Microsoft's privacy policies, located at [https://www.microsoft.com/trustcenter](https://www.microsoft.com/trustcenter).

If you don't wish to send usage data to Amesto Fortytwo, details on how to turn it off can be found [here](https://github.com/amestofortytwo/terraform-azurerm-aks#input_disable_telemetry).
<!-- END_TF_DOCS -->