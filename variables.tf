variable "name" {
  description = "The name of the managed Kubernetes cluster."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group to create the resources in"
  type        = string
}

variable "location" {
  description = "The location where all resources will be created"
  type        = string
}

variable "tags" {
  description = "(Optional) A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

variable "default_node_pool" {
  description = <<EOT
  (Optional) The default node pool for the Kubernetes cluster.
  If not specified, the default node pool will have one Standard_d2s_v4 node.
  EOT
  type = object({
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
  default = {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2s_v4"
  }
}

variable "additional_node_pools" {
  description = <<EOT
  (Optional) A list of additional node pools to add to the Kubernetes cluster.

  Each node pool can have the following properties:
  name - (Required) The name of the node pool.
  node_count - (optional) The number of nodes in the node pool, defaults to 1.
  vm_size - (optional) The size of the virtual machines to use for the node pool, defaults to the same as the default node pool.
  EOT
  type = list(object({
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
  default = []
}

variable "auto_scaler_profile" {
  description = "The auto scaler profile for the Kubernetes cluster."
  type = object({
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
  default = null
}

variable "identity" {
  description = <<EOT
  (Optional) The identity block for the Kubernetes cluster.
  If not specified, the identity will be of type SystemAssigned.
  EOT
  type = object({
    type         = string
    identity_ids = optional(list(string))
  })
  default = {
    type         = "SystemAssigned"
    identity_ids = null
  }
}

variable "aad_rbac" {
  description = <<EOT
  (Optional) Used to fill the azure_active_directory_role_based_access_control block for the Kubernetes cluster.
  If nothing is specified, managed AAD RBAC will be enabled.

  If managed is set to true, the admin_group_object_ids properties can be specified to a group that will have admin access to the cluster.
  EOT
  type = object({
    managed                = optional(bool)
    tenant_id              = optional(string)
    admin_group_object_ids = optional(list(string))
    azure_rbac_enabled     = optional(bool)
    client_app_id          = optional(string)
    server_app_id          = optional(string)
    server_app_secret      = optional(string)
  })
  default = {
    managed                = true
    azure_rbac_enabled     = true
    admin_group_object_ids = null
  }

}

variable "service_principal" {
  description = <<EOT
  (Optional) The service principal block for the Kubernetes cluster.
  Do not specify this block if you want already defined the identity block, or if you want to use the SystemAssigned identity.
  EOT
  type = object({
    client_id     = string
    client_secret = string
  })
  default = null
}

variable "network_profile" {
  description = <<EOT
  (Optional) The network profile block for the Kubernetes cluster.
  If not specified, the network profile will be of type Azure.
  EOT
  type = object({
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
  default = {
    network_plugin = "azure"
  }
}

variable "storage_profile" {
  description = "(Optional) The storage profile block for the Kubernetes cluster."
  type = object({
    blob_driver_enabled         = optional(bool)
    disk_driver_enabled         = optional(bool)
    disk_driver_version         = optional(string)
    file_driver_enabled         = optional(bool)
    snapshot_controller_enabled = optional(bool)
  })
  default = null

  validation {
    condition     = var.storage_profile == null || try(var.storage_profile.disk_driver_version == null, true) || can(regex("^(v1|v2)$", var.storage_profile.disk_driver_version))
    error_message = "Value can only be 'v1' or 'v2'."
  }
}

variable "ingress_application_gateway" {
  description = "Values used for deployment of the ingress application gateway"
  type = object({
    gateway_id   = optional(string)
    gateway_name = optional(string)
    subnet_cidr  = optional(string)
    subnet_id    = optional(string)
  })
  default = null
}

variable "kubernetes_version" {
  description = "Kubernetes version to use for the cluster"
  type        = string
  default     = null
}

variable "automatic_bump_kubernetes_version" {
  description = "Automatically bump the Kubernetes version to the latest available version"
  type = object({
    enabled         = bool
    version_prefix  = string
    include_preview = bool
  })
  default = {
    enabled         = false
    version_prefix  = "1.23"
    include_preview = false
  }
}

variable "azure_policy_enabled" {
  description = "Enable or disable Azure Policy for the cluster. Defaults to true."
  type        = bool
  default     = true
}

variable "api_server_authorized_ip_ranges" {
  description = "(Optional) A list of authorized IP ranges to access the Kubernetes API server"
  type        = list(string)
  default     = null
}

variable "workload_identity_enabled" {
  description = "(Optional) Enable or disable workload identity for the cluster. Enabling this also sets oidc_issuer_enabled to true."
  type        = bool
  default     = null
}

variable "private_cluster" {
  description = "(Optional) Enable or disable private cluster for the cluster. Defaults to false."
  type        = bool
  default     = false
}

variable "local_account_disabled" {
  description = "(Optional) Enable or disable local account for the cluster. Defaults to true."
  type        = bool
  default     = true
}

variable "disk_encryption_set_id" {
  type        = string
  default     = null
  description = "(Optional) The ID of the Disk Encryption Set which should be used for the Nodes and Volumes. More information [can be found in the documentation](https://docs.microsoft.com/azure/aks/azure-disk-customer-managed-keys). Changing this forces a new resource to be created."
}

variable "kms_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Enable Azure Key Vault Key Management Service."
  nullable    = false
}

variable "kms_key_vault_key_id" {
  type        = string
  default     = null
  description = "(Optional) Identifier of Azure Key Vault key. When Azure Key Vault key management service is enabled, this field is required and must be a valid key identifier."
}

variable "kms_key_vault_network_access" {
  type        = string
  default     = "Private"
  description = "(Optional) Network Access of Azure Key Vault. Possible values are: 'Private' and 'Public'. The default value is 'Private'."

  validation {
    condition     = contains(["Private", "Public"], var.kms_key_vault_network_access)
    error_message = "Possible values are 'Private' and 'Public'"
  }
}

variable "sku_tier" {
  description = "(Optional) The SKU Tier that should be used for this Kubernetes Cluster. Possible values are Free, and Standard (which includes the Uptime SLA). Defaults to Free."
  type        = string
  default     = "Free"

  validation {
    condition     = contains(["Free", "Standard"], var.sku_tier)
    error_message = "Value must be either Free or Standard"
  }
}

variable "automatic_channel_upgrade" {
  description = "(Optional) The upgrade channel for this Kubernetes Cluster. Possible values are patch, rapid, node-image and stable. Omitting this field sets this value to none."
  type        = string
  default     = "none"

  validation {
    condition     = contains(["patch", "rapid", "none", "stable", "node-image"], var.automatic_channel_upgrade)
    error_message = "Value must be either patch, rapid, none, stable, or node-image"
  }
}

variable "default_log_analytics_workspace_id" {
  description = <<EOF
  (Optional) The id of the Log Analytics Workspace to use as default for Defender and Azure Monitor.
  Each of these services can be configured to use a different Log Analytics Workspace, which will override this setting.
  If neither this nor the service spesific variable is specified, and the services are enabled, a new Log Analytics Workspace will be created.
  EOF
  type        = string
  default     = null
}

variable "key_vault_secrets_provider" {
  description = "(Optional) Enable or disable Azure Key Vault Secret Providers for the cluster. Defaults to false."
  type = object({
    enabled                  = optional(bool, false)
    secret_rotation_enabled  = optional(bool, false)
    secret_rotation_interval = optional(string, null)
  })
  default = {}
}

variable "microsoft_defender" {
  description = <<EOF
  (Optional) Enable or disable Microsoft Defender (Security profile) for the cluster. Defaults to false.
  If neither microsoft_defender.log_analytics_workspace_id nor default_log_analytics_workspace_id is specified, a new Log Analytics Workspace will be created with the same name as the AKS cluster and in the same resource group.
  EOF
  type = object({
    enabled                    = optional(bool, false)
    log_analytics_workspace_id = optional(string, null)
  })
  default = {
    enabled                    = false
    log_analytics_workspace_id = null
  }
}

variable "azure_monitor" {
  description = <<EOF
  (Optional) Enable or disable Azure Monitor for the cluster. Defaults to true.
  If neither azure_monitor.log_analytics_workspace_id nor default_log_analytics_workspace_id is specified, a new Log Analytics Workspace will be created with the same name as the AKS cluster and in the same resource group.
  EOF
  type = object({
    enabled                    = optional(bool, true)
    log_analytics_workspace_id = optional(string, null)
  })
  default = {
    enabled                    = true
    log_analytics_workspace_id = null
  }
}

variable "disable_telemetry" {
  type        = bool
  description = "If set to true, will disable telemetry for the module."
  default     = false
}