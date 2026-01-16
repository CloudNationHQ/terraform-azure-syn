data "azurerm_client_config" "current" {}

# workspace
resource "azurerm_synapse_workspace" "synapse_workspace" {
  resource_group_name = coalesce(
    lookup(
      var.workspace, "resource_group_name", null
    ), var.resource_group_name
  )

  location = coalesce(
    lookup(var.workspace, "location", null
    ), var.location
  )

  name                                 = var.workspace.name
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
    for_each = var.workspace.azure_devops_repo != null ? { default = var.workspace.azure_devops_repo } : {}

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
    for_each = var.workspace.customer_managed_key != null ? { default = var.workspace.customer_managed_key } : {}

    content {
      key_versionless_id        = customer_managed_key.value.key_versionless_id
      key_name                  = customer_managed_key.value.key_name
      user_assigned_identity_id = customer_managed_key.value.user_assigned_identity_id
    }
  }

  dynamic "identity" {
    for_each = var.workspace.identity != null ? [var.workspace.identity] : []

    content {
      type         = identity.value.type
      identity_ids = identity.value.identity_ids
    }
  }

  dynamic "github_repo" {
    for_each = var.workspace.github_repo != null ? { default = var.workspace.github_repo } : {}

    content {
      account_name    = github_repo.value.account_name
      branch_name     = github_repo.value.branch_name
      last_commit_id  = github_repo.value.last_commit_id
      repository_name = github_repo.value.repository_name
      root_folder     = github_repo.value.root_folder
      git_url         = github_repo.value.git_url
    }
  }

  tags = coalesce(
    var.workspace.tags, var.tags
  )
}

# aad admin
resource "azurerm_synapse_workspace_aad_admin" "synapse_workspace" {
  for_each = var.workspace.aad_admin != null ? { default = var.workspace.aad_admin } : {}

  synapse_workspace_id = azurerm_synapse_workspace.synapse_workspace.id
  login                = each.value.login
  object_id            = coalesce(each.value.object_id, data.azurerm_client_config.current.object_id)
  tenant_id            = coalesce(each.value.tenant_id, data.azurerm_client_config.current.tenant_id)
}

# firewall rules
resource "azurerm_synapse_firewall_rule" "synapse_firewall_rule" {
  for_each = var.workspace.firewall_rule

  name = coalesce(
    each.value.name,
    try(join("-", [var.naming.synapse_firewall_rule, each.key]), null),
    each.key
  )

  synapse_workspace_id = azurerm_synapse_workspace.synapse_workspace.id
  start_ip_address     = each.value.start_ip_address
  end_ip_address       = each.value.end_ip_address
}

# sql pools
resource "azurerm_synapse_sql_pool" "synapse_sql_pool" {
  for_each = var.workspace.sql_pools

  name = coalesce(
    each.value.name,
    try(join("-", [var.naming.synapse_sql_pool, each.key]), null),
    each.key
  )

  synapse_workspace_id      = azurerm_synapse_workspace.synapse_workspace.id
  sku_name                  = each.value.sku_name
  create_mode               = each.value.create_mode
  collation                 = each.value.collation
  data_encrypted            = each.value.data_encrypted
  recovery_database_id      = each.value.recovery_database_id
  geo_backup_policy_enabled = each.value.geo_backup_policy_enabled
  storage_account_type      = each.value.storage_account_type

  dynamic "restore" {
    for_each = each.value.restore != null ? { default = each.value.restore } : {}

    content {
      source_database_id = restore.value.source_database_id
      point_in_time      = restore.value.point_in_time
    }
  }

  tags = coalesce(
    var.workspace.tags, var.tags
  )
}

# spark pools
resource "azurerm_synapse_spark_pool" "synapse_spark_pool" {
  for_each = var.workspace.spark_pools

  name = coalesce(
    each.value.name,
    try(join("", [var.naming.synapse_spark_pool, each.key]), null),
    each.key
  )

  synapse_workspace_id                = azurerm_synapse_workspace.synapse_workspace.id
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

  dynamic "auto_scale" {
    for_each = each.value.auto_scale != null ? { default = each.value.auto_scale } : {}

    content {
      min_node_count = auto_scale.value.min_node_count
      max_node_count = auto_scale.value.max_node_count
    }
  }

  dynamic "auto_pause" {
    for_each = each.value.auto_pause != null ? { default = each.value.auto_pause } : {}

    content {
      delay_in_minutes = auto_pause.value.delay_in_minutes
    }
  }

  dynamic "library_requirement" {
    for_each = each.value.library_requirement != null ? { default = each.value.library_requirement } : {}

    content {
      content  = library_requirement.value.content
      filename = library_requirement.value.filename
    }
  }

  dynamic "spark_config" {
    for_each = each.value.spark_config != null ? { default = each.value.spark_config } : {}

    content {
      content  = spark_config.value.content
      filename = spark_config.value.filename
    }
  }

  tags = coalesce(
    var.workspace.tags, var.tags
  )
}

# role assignment
resource "azurerm_synapse_role_assignment" "synapse_role_assignment" {
  for_each = var.workspace.role_assignment

  synapse_workspace_id  = each.value.synapse_spark_pool_id == null ? azurerm_synapse_workspace.synapse_workspace.id : null
  synapse_spark_pool_id = each.value.synapse_spark_pool_id
  role_name             = each.value.role_name
  principal_id          = each.value.principal_id
  principal_type        = each.value.principal_type

  depends_on = [
    azurerm_synapse_firewall_rule.synapse_firewall_rule,
  ]
}

# endpoint
resource "azurerm_synapse_managed_private_endpoint" "synapse_managed_private_endpoint" {
  for_each = var.workspace.managed_private_endpoint

  name = coalesce(
    each.value.name,
    try(join("-", [var.naming.synapse_managed_private_endpoint, each.key]), null),
    each.key
  )

  synapse_workspace_id = azurerm_synapse_workspace.synapse_workspace.id
  target_resource_id   = each.value.target_resource_id
  subresource_name     = each.value.subresource_name

  depends_on = [
    azurerm_synapse_firewall_rule.synapse_firewall_rule,
  ]
}

# integration runtime self hosted
resource "azurerm_synapse_integration_runtime_self_hosted" "synapse_irsh" {
  for_each = var.workspace.integration_runtime_self_hosted

  name = coalesce(
    each.value.name,
    try(join("-", [var.naming.synapse_integration_runtime_self_hosted, each.key]), null),
    each.key
  )

  synapse_workspace_id = azurerm_synapse_workspace.synapse_workspace.id
  description          = each.value.description
}

# integration runtime azure
resource "azurerm_synapse_integration_runtime_azure" "synapse_ira" {
  for_each = var.workspace.integration_runtime_azure

  name = coalesce(
    each.value.name,
    try(join("-", [var.naming.synapse_integration_runtime_azure, each.key]), null),
    each.key
  )

  location = coalesce(
    each.value.location,
    lookup(var.workspace, "location", null),
    var.location
  )

  synapse_workspace_id = azurerm_synapse_workspace.synapse_workspace.id
  compute_type         = each.value.compute_type
  core_count           = each.value.core_count
  description          = each.value.description
  time_to_live_min     = each.value.time_to_live_min
}

# linked service
resource "azurerm_synapse_linked_service" "synapse_linked_service" {
  for_each = var.workspace.linked_service

  name = coalesce(
    each.value.name,
    try(join("-", [var.naming.synapse_linked_service, each.key]), null),
    each.key
  )

  synapse_workspace_id  = azurerm_synapse_workspace.synapse_workspace.id
  type                  = each.value.type
  type_properties_json  = each.value.type_properties_json
  additional_properties = each.value.additional_properties
  annotations           = each.value.annotations
  description           = each.value.description
  parameters            = each.value.parameters

  dynamic "integration_runtime" {
    for_each = each.value.integration_runtime != null ? { default = each.value.integration_runtime } : {}

    content {
      name       = integration_runtime.value.name
      parameters = integration_runtime.value.parameters
    }
  }

  depends_on = [
    azurerm_synapse_firewall_rule.synapse_firewall_rule,
    azurerm_synapse_integration_runtime_azure.synapse_ira,
    azurerm_synapse_integration_runtime_self_hosted.synapse_irsh
  ]
}

# workspace key
resource "azurerm_synapse_workspace_key" "workspace_key" {
  for_each = var.workspace.customer_managed_key != null ? { default = var.workspace.customer_managed_key } : {}

  customer_managed_key_versionless_id = each.value.key_versionless_id
  synapse_workspace_id                = azurerm_synapse_workspace.synapse_workspace.id
  active                              = true
  customer_managed_key_name           = each.value.key_name
}
