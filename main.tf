data "azurerm_client_config" "current" {}

# synapse workspace
resource "azurerm_synapse_workspace" "synapse_workspace" {
  name                                 = var.workspace.name
  resource_group_name                  = try(var.workspace.resource_group, var.resource_group)
  location                             = try(var.workspace.location, var.location)
  storage_data_lake_gen2_filesystem_id = var.workspace.storage_data_lake_gen2_filesystem_id
  sql_administrator_login              = var.workspace.sql_administrator_login
  sql_administrator_login_password     = var.workspace.sql_administrator_login_password
  azuread_authentication_only          = try(var.workspace.azuread_authentication_only, false)
  compute_subnet_id                    = try(var.workspace.compute_subnet_id, null)
  data_exfiltration_protection_enabled = try(var.workspace.data_exfiltration_protection_enabled, false)
  linking_allowed_for_aad_tenant_ids   = try(var.workspace.linking_allowed_for_aad_tenant_ids, [])
  managed_resource_group_name          = try(var.workspace.managed_resource_group_name, null)
  managed_virtual_network_enabled      = try(var.workspace.managed_virtual_network_enabled, false)
  public_network_access_enabled        = try(var.workspace.public_network_access_enabled, true)
  purview_id                           = try(var.workspace.purview_id, null)
  sql_identity_control_enabled         = try(var.workspace.sql_identity_control_enabled, false)

  # block
  dynamic "azure_devops_repo" {
    for_each = try(var.workspace.azure_devops_repo, null) != null ? { default = var.workspace.azure_devops_repo } : {}
    content {
      account_name    = try(azure_devops_repo.value.account_name, azure_devops_repo.key)
      branch_name     = azurure_devops_repo.value.branch_name
      last_commit_id  = try(azure_devops_repo.value.last_commit_id, null)
      project_name    = azure_devops_repo.value.project_name
      repository_name = azure_devops_repo.value.repository_name
      root_folder     = try(azure_devops_repo.value.root_folder, "/")
      tenant_id       = try(azure_devops_repo.value.tenant_id, null)
    }
  }

  # block
  dynamic "customer_managed_key" {
    for_each = try(var.workspace.customer_managed_key, null) != null ? { default = var.workspace.customer_managed_key } : {}
    content {
      key_versionless_id        = customer_managed_key.value.key_versionless_id
      key_name                  = try(customer_managed_key.value.key_name, null)
      user_assigned_identity_id = try(azurerm_user_assigned_identity.identity["identity"].id, null)
    }
  }

  # block
  dynamic "identity" {
    for_each = [lookup(var.workspace, "identity", { type = "SystemAssigned", identity_ids = [] })]

    content {
      type = identity.value.type
      identity_ids = concat(
        try([azurerm_user_assigned_identity.identity["identity"].id], []),
        lookup(identity.value, "identity_ids", [])
      )
    }
  }

  # block
  dynamic "github_repo" {
    for_each = try(var.workspace.github_repo, null) != null ? { default = var.workspace.github_repo } : {}
    content {
      account_name    = try(github_repo.value.account_name, github_repo.key)
      branch_name     = try(github_repo.value.branch_name, "main")
      last_commit_id  = try(github_repo.value.last_commit_id, null)
      repository_name = github_repo.value.repository_name
      root_folder     = try(github_repo.value.root_folder, "/")
      git_url         = try(github_repo.value.git_url, null)
    }
  }

  tags = try(var.workspace.tags, {})
}

# aad admin
resource "azurerm_synapse_workspace_aad_admin" "synapse_workspace" {
  for_each             = try(var.workspace.aad_admin, null) != null ? { default = var.workspace.aad_admin } : {}
  synapse_workspace_id = azurerm_synapse_workspace.synapse_workspace.id
  login                = each.value.login
  object_id            = try(each.value.object_id, data.azurerm_client_config.current.object_id)
  tenant_id            = try(each.value.tenant_id, data.azurerm_client_config.current.tenant_id)
}

# firewall rule
resource "azurerm_synapse_firewall_rule" "synapse_firewall_rule" {
  for_each = {
    for key, rule in try(var.workspace.firewall_rule, {}) : key => rule
  }

  synapse_workspace_id = azurerm_synapse_workspace.synapse_workspace.id
  name                 = try(each.value.name, join("-", [var.naming.synapse_firewall_rule, each.key]))
  start_ip_address     = each.value.start_ip_address
  end_ip_address       = each.value.end_ip_address
}

# sql pool
resource "azurerm_synapse_sql_pool" "synapse_sql_pool" {
  for_each = {
    for key, sql_pool in try(var.workspace.sql_pool, {}) : key => sql_pool
  }

  name                      = try(each.value.name, join("-", [var.naming.synapse_sql_pool, each.key]))
  synapse_workspace_id      = azurerm_synapse_workspace.synapse_workspace.id
  sku_name                  = each.value.sku_name
  create_mode               = try(each.value.create_mode, "Default")
  collation                 = try(each.value.collation, null)
  data_encrypted            = try(each.value.data_encrypted, null)
  recovery_database_id      = try(each.value.recovery_database_id, null)
  geo_backup_policy_enabled = try(each.value.geo_backup_policy_enabled, true)
  storage_account_type      = try(each.value.storage_account_type, "GRS")

  # Does not work as currently it is not possible to test
  dynamic "restore" {
    for_each = try(each.value.restore, null) != null ? { default = each.value.restore } : {}
    content {
      source_database_id = restore.value.source_database_id
      point_in_time      = restore.value.point_in_time
    }
  }

  tags = try(var.workspace.tags, {})

}

# spark pool
resource "azurerm_synapse_spark_pool" "synapse_spark_pool" {
  for_each = {
    for key, spark_pool in try(var.workspace.spark_pool, {}) : key => spark_pool
  }

  name                                = try(each.value.name, join("-", [var.naming.synapse_spark_pool, each.key]))
  synapse_workspace_id                = azurerm_synapse_workspace.synapse_workspace.id
  node_size_family                    = each.value.node_size_family
  node_size                           = each.value.node_size
  node_count                          = try(each.value.node_count, null)
  cache_size                          = try(each.value.cache_size, null)
  compute_isolation_enabled           = try(each.value.compute_isolation_enabled, false)
  dynamic_executor_allocation_enabled = try(each.value.dynamic_executor_allocation_enabled, false)
  min_executors                       = try(each.value.min_executors, null)
  max_executors                       = try(each.value.max_executors, null)
  session_level_packages_enabled      = try(each.value.session_level_packages_enabled, false)
  spark_log_folder                    = try(each.value.spark_log_folder, "/logs")
  spark_events_folder                 = try(each.value.spark_events_folder, "/events")
  spark_version                       = try(each.value.spark_version, "2.4")

  dynamic "auto_scale" {
    for_each = try(each.value.auto_scale, null) != null ? { default = each.value.auto_scale } : {}
    content {
      min_node_count = auto_scale.value.min_node_count
      max_node_count = auto_scale.value.max_node_count
    }
  }

  dynamic "auto_pause" {
    for_each = try(each.value.auto_pause, null) != null ? { default = each.value.auto_pause } : {}
    content {
      delay_in_minutes = auto_pause.value.delay_in_minutes
    }
  }

  dynamic "library_requirement" {
    for_each = try(each.value.library_requirement, null) != null ? { default = each.value.library_requirement } : {}
    content {
      content  = library_requirement.value.content
      filename = library_requirement.value.filename
    }
  }

  dynamic "spark_config" {
    for_each = try(each.value.spark_config, null) != null ? { default = each.value.spark_config } : {}
    content {
      content  = spark_config.value.content
      filename = spark_config.value.filename
    }
  }

  tags = try(var.workspace.tags, {})
}

# role assignment
resource "azurerm_synapse_role_assignment" "synapse_role_assignment" {
  for_each = {
    for key, role_assignment in try(var.workspace.role_assignment, {}) : key => role_assignment
  }

  synapse_workspace_id = azurerm_synapse_workspace.synapse_workspace.id
  role_name            = each.value.role_name
  principal_id         = each.value.principal_id
  principal_type       = each.value.principal_type
}


# managed_private_endpoint
resource "azurerm_synapse_managed_private_endpoint" "synapse_managed_private_endpoint" {
  for_each = {
    for key, managed_pe in try(var.workspace.managed_private_endpoint, {}) : key => managed_pe
  }

  name                 = try(each.value.name, join("-", [var.naming.synapse_managed_private_endpoint, each.key]))
  synapse_workspace_id = azurerm_synapse_workspace.synapse_workspace.id
  target_resource_id   = each.value.target_resource_id
  subresource_name     = each.value.subresource_name
}

# user assigned identity
resource "azurerm_user_assigned_identity" "identity" {
  for_each = contains(["UserAssigned", "SystemAssigned, UserAssigned"], try(var.workspace.identity.type, "")) ? { "identity" = var.workspace.identity } : {}

  name                = try(each.value.name, "uai-${var.workspace.name}")
  resource_group_name = var.workspace.resource_group
  location            = var.workspace.location
  tags                = try(var.workspace.tags, {})
}

# integration runtime self hosted
resource "azurerm_synapse_integration_runtime_self_hosted" "synapse_irsh" {
  for_each = {
    for key, irsh in try(var.workspace.integration_runtime_self_hosted, {}) : key => irsh
  }

  name                 = try(each.value.name, join("-", [var.naming.synapse_integration_runtime_self_hosted, each.key]))
  synapse_workspace_id = azurerm_synapse_workspace.synapse_workspace.id
}

# integration runtime azure
resource "azurerm_synapse_integration_runtime_azure" "synapse_ira" {
  for_each = {
    for key, ira in try(var.workspace.integration_runtime_azure, {}) : key => ira
  }

  name                 = try(each.value.name, join("-", [var.naming.synapse_integration_runtime_azure, each.key]))
  synapse_workspace_id = azurerm_synapse_workspace.synapse_workspace.id
  location             = try(each.value.location, var.workspace.location)
}

# linked service
resource "azurerm_synapse_linked_service" "synapse_linked_service" {
  for_each = {
    for key, linked_service in try(var.workspace.linked_service, {}) : key => linked_service
  }

  name                  = try(each.value.name, join("-", [var.naming.synapse_linked_service, each.key]))
  synapse_workspace_id  = azurerm_synapse_workspace.synapse_workspace.id
  type                  = each.value.type
  type_properties_json  = each.value.type_properties_json
  additional_properties = try(each.value.additional_properties, null)
  annotations           = try(each.value.annotations, null)
  description           = try(each.value.description, null)
  parameters            = try(each.value.parameters, null)

  dynamic "integration_runtime" {
    for_each = try(each.value.integration_runtime, null) != null ? { default = each.value.integration_runtime } : {}
    content {
      name       = integration_runtime.value.name
      parameters = try(integration_runtime.value.parameters, null)
    }
  }

  depends_on = [
    azurerm_synapse_firewall_rule.synapse_firewall_rule
  ]
}

# workspace key
resource "azurerm_synapse_workspace_key" "workspace_key" {
  for_each                            = try(var.workspace.customer_managed_key, null) != null ? { default = var.workspace.customer_managed_key } : {}
  customer_managed_key_versionless_id = each.value.key_versionless_id
  synapse_workspace_id                = azurerm_synapse_workspace.synapse_workspace.id
  active                              = true
  customer_managed_key_name           = each.value.key_name
}