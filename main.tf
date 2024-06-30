/*
* # Azure Kubernetes Service
*
* This is the repository for our Azure Kubernetes Service (AKS) Terraform module.
*/

resource "azurerm_log_analytics_workspace" "main" {
  count               = (var.azure_monitor.enabled && null == var.azure_monitor.log_analytics_workspace_id && null == var.default_log_analytics_workspace_id) || (var.microsoft_defender.enabled && null == var.microsoft_defender.log_analytics_workspace_id && null == var.default_log_analytics_workspace_id) ? 1 : 0
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = local.tags
}

resource "azurerm_kubernetes_cluster" "main" {
  name                         = var.name
  location                     = var.location
  resource_group_name          = var.resource_group_name
  dns_prefix                   = replace(var.name, "-", "")
  kubernetes_version           = local.kubernetes_version
  azure_policy_enabled         = var.azure_policy_enabled
  workload_identity_enabled    = var.workload_identity_enabled
  oidc_issuer_enabled          = var.workload_identity_enabled == true ? true : null
  private_cluster_enabled      = var.private_cluster
  private_dns_zone_id          = var.private_dns_zone_id
  local_account_disabled       = var.local_account_disabled
  sku_tier                     = var.sku_tier
  automatic_channel_upgrade    = var.automatic_channel_upgrade
  disk_encryption_set_id       = var.disk_encryption_set_id
  run_command_enabled          = var.run_command_enabled
  image_cleaner_enabled        = var.image_cleaner_enabled
  image_cleaner_interval_hours = var.image_cleaner_interval_hours
  node_os_channel_upgrade      = var.node_os_channel_upgrade

  dynamic "api_server_access_profile" {
    for_each = var.api_server_authorized_ip_ranges != null ? [1] : []
    content {
      authorized_ip_ranges = var.api_server_authorized_ip_ranges
    }
  }

  dynamic "auto_scaler_profile" {
    for_each = var.auto_scaler_profile != null ? [1] : []
    content {
      balance_similar_node_groups      = var.auto_scaler_profile.balance_similar_node_groups
      expander                         = var.auto_scaler_profile.expander
      max_graceful_termination_sec     = var.auto_scaler_profile.max_graceful_termination_sec
      max_node_provisioning_time       = var.auto_scaler_profile.max_node_provisioning_time
      max_unready_nodes                = var.auto_scaler_profile.max_unready_nodes
      new_pod_scale_up_delay           = var.auto_scaler_profile.new_pod_scale_up_delay
      scale_down_delay_after_add       = var.auto_scaler_profile.scale_down_delay_after_add
      scale_down_delay_after_delete    = var.auto_scaler_profile.scale_down_delay_after_delete
      scale_down_delay_after_failure   = var.auto_scaler_profile.scale_down_delay_after_failure
      scale_down_unneeded              = var.auto_scaler_profile.scale_down_unneeded
      scale_down_unready               = var.auto_scaler_profile.scale_down_unready
      scale_down_utilization_threshold = var.auto_scaler_profile.scale_down_utilization_threshold
      empty_bulk_delete_max            = var.auto_scaler_profile.empty_bulk_delete_max
      skip_nodes_with_local_storage    = var.auto_scaler_profile.skip_nodes_with_local_storage
      skip_nodes_with_system_pods      = var.auto_scaler_profile.skip_nodes_with_system_pods
    }
  }

  default_node_pool {
    name                 = var.default_node_pool.name
    node_count           = var.default_node_pool.node_count
    enable_auto_scaling  = var.default_node_pool.enable_auto_scaling
    min_count            = var.default_node_pool.autoscale != null ? var.default_node_pool.autoscale.min_count : null
    max_count            = var.default_node_pool.autoscale != null ? var.default_node_pool.autoscale.max_count : null
    vm_size              = var.default_node_pool.vm_size
    vnet_subnet_id       = var.network_profile.vnet_subnet_id
    orchestrator_version = lookup(var.default_node_pool, "orchestration_version", false) ? var.default_node_pool.orchestration_version : local.kubernetes_version

    # Optional settings
    max_pods                      = var.default_node_pool.max_pods
    capacity_reservation_group_id = var.default_node_pool.capacity_reservation_group_id
    enable_host_encryption        = var.default_node_pool.enable_host_encryption
    enable_node_public_ip         = var.default_node_pool.enable_node_public_ip
    fips_enabled                  = var.default_node_pool.fips_enabled
    kubelet_disk_type             = var.default_node_pool.kubelet_disk_type
    message_of_the_day            = var.default_node_pool.message_of_the_day
    node_public_ip_prefix_id      = var.default_node_pool.node_public_ip_prefix_id
    node_labels                   = var.default_node_pool.node_labels
    node_taints                   = var.default_node_pool.node_taints
    only_critical_addons_enabled  = var.default_node_pool.only_critical_addons_enabled
    os_disk_size_gb               = var.default_node_pool.os_disk_size_gb
    os_disk_type                  = var.default_node_pool.os_disk_type
    os_sku                        = var.default_node_pool.os_sku
    pod_subnet_id                 = var.default_node_pool.pod_subnet_id
    scale_down_mode               = var.default_node_pool.scale_down_mode
    type                          = var.default_node_pool.type
    ultra_ssd_enabled             = var.default_node_pool.ultra_ssd_enabled
    zones                         = var.default_node_pool.zones

    dynamic "kubelet_config" {
      for_each = var.default_node_pool.kubelet_config != null ? [1] : []

      content {
        cpu_manager_policy        = var.default_node_pool.kubelet_config.cpu_manager_policy
        cpu_cfs_quota_enabled     = var.default_node_pool.kubelet_config.cpu_cfs_quota
        cpu_cfs_quota_period      = var.default_node_pool.kubelet_config.cpu_cfs_quota_period
        image_gc_high_threshold   = var.default_node_pool.kubelet_config.image_gc_high_threshold
        image_gc_low_threshold    = var.default_node_pool.kubelet_config.image_gc_low_threshold
        topology_manager_policy   = var.default_node_pool.kubelet_config.topology_manager_policy
        allowed_unsafe_sysctls    = var.default_node_pool.kubelet_config.allowed_unsafe_sysctls
        container_log_max_size_mb = var.default_node_pool.kubelet_config.container_log_max_size_mb
        container_log_max_line    = var.default_node_pool.kubelet_config.container_log_max_line
        pod_max_pid               = var.default_node_pool.kubelet_config.pod_max_pids
      }
    }

    dynamic "linux_os_config" {
      for_each = var.default_node_pool.linux_os_config != null ? [1] : []

      content {
        swap_file_size_mb             = var.default_node_pool.linux_os_config.swap_file_size_mb
        transparent_huge_page_enabled = var.default_node_pool.linux_os_config.transparent_huge_page_enabled
        transparent_huge_page_defrag  = var.default_node_pool.linux_os_config.transparent_huge_page_defrag

      }
    }

    dynamic "upgrade_settings" {
      for_each = var.default_node_pool.upgrade_settings != null ? ["upgrade_settings"] : []
      content {
        max_surge = var.default_node_pool.upgrade_settings.max_surge
      }
    }

    tags = merge(
      local.tags,
      var.default_node_pool.tags,
    )
  }

  azure_active_directory_role_based_access_control {
    managed                = var.aad_rbac.managed
    tenant_id              = var.aad_rbac.tenant_id
    admin_group_object_ids = var.aad_rbac.admin_group_object_ids
    azure_rbac_enabled     = var.aad_rbac.azure_rbac_enabled
    client_app_id          = var.aad_rbac.client_app_id
    server_app_id          = var.aad_rbac.server_app_id
    server_app_secret      = var.aad_rbac.server_app_secret
  }

  dynamic "identity" {
    # Identity block is active if the service_principal variable is not set
    for_each = var.service_principal == null ? [1] : []
    content {
      type         = var.identity.type
      identity_ids = var.identity.identity_ids
    }
  }

  dynamic "service_principal" {
    # Service principal block is active if the service_principal variable is set
    for_each = var.service_principal != null ? [1] : []
    content {
      client_id     = var.service_principal.client_id
      client_secret = var.service_principal.client_secret
    }
  }

  dynamic "key_management_service" {
    for_each = var.kms_enabled ? ["key_management_service"] : []

    content {
      key_vault_key_id         = var.kms_key_vault_key_id
      key_vault_network_access = var.kms_key_vault_network_access
    }
  }

  # Network related settings
  network_profile {
    network_plugin      = var.network_profile.network_plugin
    network_policy      = var.network_profile.network_policy
    network_plugin_mode = var.network_profile.network_plugin_mode
    load_balancer_sku   = var.network_profile.load_balancer_sku
    outbound_type       = var.network_profile.outbound_type
    dns_service_ip      = var.network_profile.dns_service_ip
    docker_bridge_cidr  = var.network_profile.docker_bridge_cidr
    pod_cidr            = var.network_profile.pod_cidr
    pod_cidrs           = var.network_profile.pod_cidrs
    service_cidr        = var.network_profile.service_cidr
    service_cidrs       = var.network_profile.service_cidrs
    ip_versions         = var.network_profile.ip_versions
    network_mode        = var.network_profile.network_mode
    ebpf_data_plane     = var.network_profile.ebpf_data_plane
  }

  # Storage related settings
  dynamic "storage_profile" {
    for_each = var.storage_profile != null ? [1] : []
    content {
      blob_driver_enabled         = var.storage_profile.blob_driver_enabled
      disk_driver_enabled         = var.storage_profile.disk_driver_enabled
      disk_driver_version         = var.storage_profile.disk_driver_version
      file_driver_enabled         = var.storage_profile.file_driver_enabled
      snapshot_controller_enabled = var.storage_profile.snapshot_controller_enabled
    }
  }

  dynamic "key_vault_secrets_provider" {
    for_each = var.key_vault_secrets_provider.enabled ? [1] : []
    content {
      secret_rotation_enabled  = var.key_vault_secrets_provider.secret_rotation_enabled
      secret_rotation_interval = var.key_vault_secrets_provider.secret_rotation_interval != null ? var.key_vault_secrets_provider.secret_rotation_interval : "2m"
    }
  }

  dynamic "microsoft_defender" {
    for_each = var.microsoft_defender.enabled ? [1] : []
    content {
      log_analytics_workspace_id = var.microsoft_defender.log_analytics_workspace_id != null ? var.microsoft_defender.log_analytics_workspace_id : var.default_log_analytics_workspace_id != null ? var.default_log_analytics_workspace_id : azurerm_log_analytics_workspace.main[0].id
    }
  }

  dynamic "oms_agent" {
    for_each = var.azure_monitor.enabled ? [1] : []
    content {
      log_analytics_workspace_id = var.azure_monitor.log_analytics_workspace_id != null ? var.azure_monitor.log_analytics_workspace_id : var.default_log_analytics_workspace_id != null ? var.default_log_analytics_workspace_id : azurerm_log_analytics_workspace.main[0].id
    }
  }

  dynamic "ingress_application_gateway" {
    for_each = var.ingress_application_gateway != null ? [1] : []
    content {
      gateway_name = var.ingress_application_gateway.gateway_name
      gateway_id   = var.ingress_application_gateway.gateway_id
      subnet_cidr  = var.ingress_application_gateway.subnet_cidr
      subnet_id    = var.ingress_application_gateway.subnet_id
    }
  }

  dynamic "maintenance_window" {
    for_each = var.maintenance_window != null ? [1] : []
    content {
      dynamic "allowed" {
        for_each = var.maintenance_window.allowed
        content {
          day   = allowed.value.day
          hours = allowed.value.hours
        }
      }

      dynamic "not_allowed" {
        for_each = var.maintenance_window.not_allowed
        content {
          end   = not_allowed.value.end
          start = not_allowed.value.start
        }
      }
    }
  }

  dynamic "maintenance_window_auto_upgrade" {
    for_each = var.maintenance_window_auto_upgrade != null ? [1] : []
    content {
      duration     = maintenance_window_auto_upgrade.value.duration
      frequency    = maintenance_window_auto_upgrade.value.frequency
      interval     = maintenance_window_auto_upgrade.value.interval
      day_of_month = maintenance_window_auto_upgrade.value.day_of_month
      day_of_week  = maintenance_window_auto_upgrade.value.day_of_week
      start_date   = maintenance_window_auto_upgrade.value.start_date
      start_time   = maintenance_window_auto_upgrade.value.start_time
      utc_offset   = maintenance_window_auto_upgrade.value.utc_offset
      week_index   = maintenance_window_auto_upgrade.value.week_index

      dynamic "not_allowed" {
        for_each = maintenance_window_auto_upgrade.value.not_allowed != null ? maintenance_window_auto_upgrade.value.not_allowed : []
        content {
          end   = not_allowed.value.end
          start = not_allowed.value.start
        }
      }
    }
  }

  dynamic "maintenance_window_node_os" {
    for_each = var.maintenance_window_node_os != null ? [1] : []
    content {
      duration     = maintenance_window_node_os.value.duration
      frequency    = maintenance_window_node_os.value.frequency
      interval     = maintenance_window_node_os.value.interval
      day_of_month = maintenance_window_node_os.value.day_of_month
      day_of_week  = maintenance_window_node_os.value.day_of_week
      start_date   = maintenance_window_node_os.value.start_date
      start_time   = maintenance_window_node_os.value.start_time
      utc_offset   = maintenance_window_node_os.value.utc_offset
      week_index   = maintenance_window_node_os.value.week_index

      dynamic "not_allowed" {
        for_each = maintenance_window_node_os.value.not_allowed != null ? maintenance_window_node_os.value.not_allowed : []
        content {
          end   = not_allowed.value.end
          start = not_allowed.value.start
        }
      }
    }
  }

  lifecycle {
    precondition {
      condition     = (!(var.local_account_disabled == true && var.aad_rbac.managed == false))
      error_message = <<EOF
If local_account_disabled is set to true, it is required to enable Kubernetes RBAC and AKS-managed Azure AD integration. 
See the documentation for more information (https://docs.microsoft.com/azure/aks/managed-aad#azure-ad-authentication-overview).
      EOF
    }
  }

  tags = local.tags
}

resource "azurerm_kubernetes_cluster_node_pool" "additional" {
  for_each = { for np in var.additional_node_pools : np.name => np }

  name                  = each.value.name
  os_type               = each.value.os_type
  os_sku                = each.value.os_sku
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  node_count            = each.value.node_count
  vm_size               = each.value.vm_size == null ? var.default_node_pool.vm_size : each.value.vm_size
  vnet_subnet_id        = var.network_profile.vnet_subnet_id
  pod_subnet_id         = each.value.pod_subnet_id
  orchestrator_version  = each.value.orchestrator_version == null ? local.kubernetes_version : each.value.orchestrator_version
  max_pods              = each.value.max_pods
  node_labels           = each.value.node_labels
  node_taints           = each.value.node_taints
  priority              = each.value.priority
  spot_max_price        = each.value.spot_max_price
  eviction_policy       = each.value.eviction_policy
  enable_auto_scaling   = each.value.enable_auto_scaling
  min_count             = each.value.min_count
  max_count             = each.value.max_count
  os_disk_size_gb       = each.value.os_disk_size_gb
  os_disk_type          = each.value.os_disk_type
  kubelet_disk_type     = each.value.kubelet_disk_type
  ultra_ssd_enabled     = each.value.ultra_ssd_enabled
  zones                 = each.value.zones

  dynamic "linux_os_config" {
    for_each = each.value.linux_os_config != null ? [1] : []

    content {
      swap_file_size_mb             = each.value.linux_os_config.swap_file_size_mb
      transparent_huge_page_enabled = each.value.linux_os_config.transparent_huge_page_enabled
      transparent_huge_page_defrag  = each.value.linux_os_config.transparent_huge_page_defrag

      dynamic "sysctl_config" {
        for_each = each.value.linux_os_config.sysctl_config != null ? [1] : []

        content {
          vm_max_map_count = each.value.linux_os_config.sysctl_config.vm_max_map_count
        }
      }
    }
  }

  dynamic "upgrade_settings" {
    for_each = each.value.upgrade_settings != null ? ["upgrade_settings"] : []
    content {
      max_surge = each.value.upgrade_settings.max_surge
    }
  }

  tags = merge(local.tags, each.value.tags)
}
