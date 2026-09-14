data "azurerm_client_config" "this" {}

# workspace
resource "azurerm_synapse_workspace" "this" {
  name                = var.workspace.name
  resource_group_name = coalesce(var.workspace.resource_group_name, var.resource_group_name)
  location            = coalesce(var.workspace.location, var.location)
  tags                = coalesce(var.workspace.tags, var.tags)

  storage_data_lake_gen2_filesystem_id = var.workspace.storage_data_lake_gen2_filesystem_id
  sql_administrator_login              = var.workspace.sql_administrator_login
  sql_administrator_login_password     = var.workspace.sql_administrator_login_password
  azuread_authentication_only          = var.workspace.azuread_authentication_only
  compute_subnet_id                    = var.workspace.compute_subnet_id
  data_exfiltration_protection_enabled = var.workspace.data_exfiltration_protection_enabled
  linking_allowed_for_aad_tenant_ids   = var.workspace.linking_allowed_for_aad_tenant_ids
  managed_resource_group_name          = var.workspace.managed_resource_group_name
  managed_virtual_network_enabled      = var.workspace.managed_virtual_network_enabled
  public_network_access_enabled        = var.workspace.public_network_access_enabled
  purview_id                           = var.workspace.purview_id
  sql_identity_control_enabled         = var.workspace.sql_identity_control_enabled

  dynamic "azure_devops_repo" {
    for_each = var.workspace.azure_devops_repo != null ? { "this" = var.workspace.azure_devops_repo } : {}

    content {
      account_name    = azure_devops_repo.value.account_name
      branch_name     = azure_devops_repo.value.branch_name
      last_commit_id  = azure_devops_repo.value.last_commit_id
      project_name    = azure_devops_repo.value.project_name
      repository_name = azure_devops_repo.value.repository_name
      root_folder     = azure_devops_repo.value.root_folder
      tenant_id       = azure_devops_repo.value.tenant_id
    }
  }

  dynamic "customer_managed_key" {
    for_each = var.workspace.customer_managed_key != null ? { "this" = var.workspace.customer_managed_key } : {}

    content {
      key_versionless_id        = customer_managed_key.value.key_versionless_id
      key_name                  = customer_managed_key.value.key_name
      user_assigned_identity_id = customer_managed_key.value.user_assigned_identity_id
    }
  }

  dynamic "identity" {
    for_each = var.workspace.identity != null ? { "this" = var.workspace.identity } : {}

    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  dynamic "github_repo" {
    for_each = var.workspace.github_repo != null ? { "this" = var.workspace.github_repo } : {}

    content {
      account_name    = github_repo.value.account_name
      branch_name     = github_repo.value.branch_name
      last_commit_id  = github_repo.value.last_commit_id
      repository_name = github_repo.value.repository_name
      root_folder     = github_repo.value.root_folder
      git_url         = github_repo.value.git_url
    }
  }
}

# private endpoints
resource "azurerm_private_endpoint" "this" {
  for_each = var.workspace.private_endpoints != null ? var.workspace.private_endpoints : {}

  name                          = coalesce(each.value.name, each.key)
  resource_group_name           = coalesce(var.workspace.resource_group_name, var.resource_group_name)
  location                      = coalesce(var.workspace.location, var.location)
  subnet_id                     = each.value.subnet_resource_id
  custom_network_interface_name = each.value.custom_network_interface_name
  tags                          = coalesce(each.value.tags, var.tags)

  private_service_connection {
    name                           = coalesce(each.value.private_service_connection_name, "${each.key}-connection")
    is_manual_connection           = each.value.is_manual_connection
    private_connection_resource_id = azurerm_synapse_workspace.this.id
    subresource_names              = each.value.subresource_name != null ? [each.value.subresource_name] : []
    request_message                = each.value.request_message
  }

  dynamic "private_dns_zone_group" {
    for_each = each.value.private_dns_zone_resource_ids != null ? { "this" = each.value.private_dns_zone_resource_ids } : {}

    content {
      name                 = "default"
      private_dns_zone_ids = private_dns_zone_group.value
    }
  }

  dynamic "ip_configuration" {
    for_each = each.value.ip_configurations != null ? each.value.ip_configurations : {}

    content {
      name               = ip_configuration.value.name
      private_ip_address = ip_configuration.value.private_ip_address
      member_name        = ip_configuration.value.member_name
      subresource_name   = ip_configuration.value.subresource_name
    }
  }
}

# aad admin
resource "azurerm_synapse_workspace_aad_admin" "this" {
  for_each = var.workspace.aad_admin != null ? { "this" = var.workspace.aad_admin } : {}

  synapse_workspace_id = azurerm_synapse_workspace.this.id
  login                = each.value.login
  object_id            = coalesce(each.value.object_id, data.azurerm_client_config.this.object_id)
  tenant_id            = coalesce(each.value.tenant_id, data.azurerm_client_config.this.tenant_id)
}

# firewall rules
resource "azurerm_synapse_firewall_rule" "this" {
  for_each = var.workspace.firewall_rule

  name                 = coalesce(each.value.name, each.key)
  synapse_workspace_id = azurerm_synapse_workspace.this.id
  start_ip_address     = each.value.start_ip_address
  end_ip_address       = each.value.end_ip_address
}

# sql pools
resource "azurerm_synapse_sql_pool" "this" {
  for_each = var.workspace.sql_pools

  name                      = coalesce(each.value.name, each.key)
  synapse_workspace_id      = azurerm_synapse_workspace.this.id
  sku_name                  = each.value.sku_name
  create_mode               = each.value.create_mode
  collation                 = each.value.collation
  data_encrypted            = each.value.data_encrypted
  recovery_database_id      = each.value.recovery_database_id
  geo_backup_policy_enabled = each.value.geo_backup_policy_enabled
  storage_account_type      = each.value.storage_account_type
  tags                      = coalesce(var.workspace.tags, var.tags)

  dynamic "restore" {
    for_each = each.value.restore != null ? { "this" = each.value.restore } : {}

    content {
      source_database_id = restore.value.source_database_id
      point_in_time      = restore.value.point_in_time
    }
  }
}

# spark pools
resource "azurerm_synapse_spark_pool" "this" {
  for_each = var.workspace.spark_pools

  name                                = coalesce(each.value.name, each.key)
  synapse_workspace_id                = azurerm_synapse_workspace.this.id
  node_size_family                    = each.value.node_size_family
  node_size                           = each.value.node_size
  node_count                          = each.value.node_count
  cache_size                          = each.value.cache_size
  compute_isolation_enabled           = each.value.compute_isolation_enabled
  dynamic_executor_allocation_enabled = each.value.dynamic_executor_allocation_enabled
  min_executors                       = each.value.min_executors
  max_executors                       = each.value.max_executors
  session_level_packages_enabled      = each.value.session_level_packages_enabled
  spark_log_folder                    = each.value.spark_log_folder
  spark_events_folder                 = each.value.spark_events_folder
  spark_version                       = each.value.spark_version
  tags                                = coalesce(var.workspace.tags, var.tags)

  dynamic "auto_scale" {
    for_each = each.value.auto_scale != null ? { "this" = each.value.auto_scale } : {}

    content {
      min_node_count = auto_scale.value.min_node_count
      max_node_count = auto_scale.value.max_node_count
    }
  }

  dynamic "auto_pause" {
    for_each = each.value.auto_pause != null ? { "this" = each.value.auto_pause } : {}

    content {
      delay_in_minutes = auto_pause.value.delay_in_minutes
    }
  }

  dynamic "library_requirement" {
    for_each = each.value.library_requirement != null ? { "this" = each.value.library_requirement } : {}

    content {
      content  = library_requirement.value.content
      filename = library_requirement.value.filename
    }
  }

  dynamic "spark_config" {
    for_each = each.value.spark_config != null ? { "this" = each.value.spark_config } : {}

    content {
      content  = spark_config.value.content
      filename = spark_config.value.filename
    }
  }
}

# role assignments
resource "azurerm_synapse_role_assignment" "this" {
  for_each = var.workspace.role_assignment

  synapse_workspace_id  = each.value.synapse_spark_pool_id == null ? azurerm_synapse_workspace.this.id : null
  synapse_spark_pool_id = each.value.synapse_spark_pool_id
  role_name             = each.value.role_name
  principal_id          = each.value.principal_id
  principal_type        = each.value.principal_type

  # managed via the workspace dev endpoint (data plane), not ARM — needs the
  # private endpoint up first when public_network_access_enabled is false
  depends_on = [
    azurerm_synapse_firewall_rule.this,
    azurerm_private_endpoint.this,
  ]
}

# managed private endpoints
resource "azurerm_synapse_managed_private_endpoint" "this" {
  for_each = var.workspace.managed_private_endpoint

  name                         = coalesce(each.value.name, each.key)
  synapse_workspace_id         = azurerm_synapse_workspace.this.id
  target_resource_id           = each.value.target_resource_id
  subresource_name             = each.value.subresource_name
  fully_qualified_domain_names = each.value.fully_qualified_domain_names

  # managed via the workspace dev endpoint (data plane), not ARM — needs the
  # private endpoint up first when public_network_access_enabled is false
  depends_on = [
    azurerm_synapse_firewall_rule.this,
    azurerm_private_endpoint.this,
  ]
}

# integration runtime self hosted
resource "azurerm_synapse_integration_runtime_self_hosted" "this" {
  for_each = var.workspace.integration_runtime_self_hosted

  name                 = coalesce(each.value.name, each.key)
  synapse_workspace_id = azurerm_synapse_workspace.this.id
  description          = each.value.description
}

# integration runtime azure
resource "azurerm_synapse_integration_runtime_azure" "this" {
  for_each = var.workspace.integration_runtime_azure

  name = coalesce(each.value.name, each.key)

  location = coalesce(
    each.value.location,
    var.workspace.location,
    var.location
  )

  synapse_workspace_id = azurerm_synapse_workspace.this.id
  compute_type         = each.value.compute_type
  core_count           = each.value.core_count
  description          = each.value.description
  time_to_live_min     = each.value.time_to_live_min
}

# linked services
resource "azurerm_synapse_linked_service" "this" {
  for_each = var.workspace.linked_service

  name                  = coalesce(each.value.name, each.key)
  synapse_workspace_id  = azurerm_synapse_workspace.this.id
  type                  = each.value.type
  type_properties_json  = each.value.type_properties_json
  additional_properties = each.value.additional_properties
  annotations           = each.value.annotations
  description           = each.value.description
  parameters            = each.value.parameters

  dynamic "integration_runtime" {
    for_each = each.value.integration_runtime != null ? { "this" = each.value.integration_runtime } : {}

    content {
      name       = integration_runtime.value.name
      parameters = integration_runtime.value.parameters
    }
  }

  # managed via the workspace dev endpoint (data plane), not ARM — needs the
  # private endpoint up first when public_network_access_enabled is false
  depends_on = [
    azurerm_synapse_firewall_rule.this,
    azurerm_synapse_integration_runtime_azure.this,
    azurerm_synapse_integration_runtime_self_hosted.this,
    azurerm_private_endpoint.this,
  ]
}

# workspace key
resource "azurerm_synapse_workspace_key" "this" {
  for_each = var.workspace.customer_managed_key != null ? { "this" = var.workspace.customer_managed_key } : {}

  customer_managed_key_versionless_id = each.value.key_versionless_id
  synapse_workspace_id                = azurerm_synapse_workspace.this.id
  active                              = true
  customer_managed_key_name           = each.value.key_name
}
