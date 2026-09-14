variable "workspace" {
  description = "describes the synapse workspace configuration"
  type = object({
    name                                 = string
    resource_group_name                  = optional(string)
    location                             = optional(string)
    storage_data_lake_gen2_filesystem_id = string
    sql_administrator_login              = string
    sql_administrator_login_password     = string
    azuread_authentication_only          = optional(bool)
    compute_subnet_id                    = optional(string)
    data_exfiltration_protection_enabled = optional(bool)
    linking_allowed_for_aad_tenant_ids   = optional(list(string))
    managed_resource_group_name          = optional(string)
    managed_virtual_network_enabled      = optional(bool)
    public_network_access_enabled        = optional(bool)
    purview_id                           = optional(string)
    sql_identity_control_enabled         = optional(bool)
    tags                                 = optional(map(string))
    azure_devops_repo = optional(object({
      account_name    = string
      branch_name     = string
      last_commit_id  = optional(string)
      project_name    = string
      repository_name = string
      root_folder     = string
      tenant_id       = optional(string)
    }))
    customer_managed_key = optional(object({
      key_versionless_id        = string
      key_name                  = optional(string, "cmk")
      user_assigned_identity_id = optional(string)
    }))
    identity = optional(object({
      type         = string
      identity_ids = optional(list(string))
    }))
    github_repo = optional(object({
      account_name    = string
      branch_name     = string
      last_commit_id  = optional(string)
      repository_name = string
      root_folder     = string
      git_url         = optional(string)
    }))
    aad_admin = optional(object({
      login     = string
      object_id = optional(string)
      tenant_id = optional(string)
    }))
    private_endpoints = optional(map(object({
      name                            = optional(string)
      subnet_resource_id              = string
      subresource_name                = optional(string)
      private_dns_zone_resource_ids   = optional(list(string))
      custom_network_interface_name   = optional(string)
      tags                            = optional(map(string))
      private_service_connection_name = optional(string)
      is_manual_connection            = optional(bool, false)
      request_message                 = optional(string)
      ip_configurations = optional(map(object({
        name               = optional(string)
        private_ip_address = optional(string)
        member_name        = optional(string)
        subresource_name   = optional(string)
      })))
    })))
    firewall_rule = optional(map(object({
      name             = optional(string)
      start_ip_address = string
      end_ip_address   = string
    })), {})
    sql_pools = optional(map(object({
      name                      = optional(string)
      sku_name                  = string
      create_mode               = optional(string)
      collation                 = optional(string)
      data_encrypted            = optional(bool)
      recovery_database_id      = optional(string)
      geo_backup_policy_enabled = optional(bool)
      storage_account_type      = string
      restore = optional(object({
        source_database_id = string
        point_in_time      = string
      }))
    })), {})
    spark_pools = optional(map(object({
      name                                = optional(string)
      node_size_family                    = string
      node_size                           = string
      node_count                          = optional(number)
      cache_size                          = optional(number)
      compute_isolation_enabled           = optional(bool)
      dynamic_executor_allocation_enabled = optional(bool)
      min_executors                       = optional(number)
      max_executors                       = optional(number)
      session_level_packages_enabled      = optional(bool)
      spark_log_folder                    = optional(string)
      spark_events_folder                 = optional(string)
      spark_version                       = string
      auto_scale = optional(object({
        min_node_count = number
        max_node_count = number
      }))
      auto_pause = optional(object({
        delay_in_minutes = number
      }))
      library_requirement = optional(object({
        content  = string
        filename = string
      }))
      spark_config = optional(object({
        content  = string
        filename = string
      }))
    })), {})
    role_assignment = optional(map(object({
      role_name             = string
      principal_id          = string
      principal_type        = optional(string)
      synapse_spark_pool_id = optional(string)
    })), {})
    managed_private_endpoint = optional(map(object({
      name                         = optional(string)
      target_resource_id           = string
      subresource_name             = string
      fully_qualified_domain_names = optional(list(string))
    })), {})
    integration_runtime_self_hosted = optional(map(object({
      name        = optional(string)
      description = optional(string)
    })), {})
    integration_runtime_azure = optional(map(object({
      name             = optional(string)
      location         = optional(string)
      compute_type     = optional(string)
      core_count       = optional(number)
      description      = optional(string)
      time_to_live_min = optional(number)
    })), {})
    linked_service = optional(map(object({
      name                  = optional(string)
      type                  = string
      type_properties_json  = string
      additional_properties = optional(map(string))
      annotations           = optional(list(string))
      description           = optional(string)
      parameters            = optional(map(string))
      integration_runtime = optional(object({
        name       = string
        parameters = optional(map(string))
      }))
    })), {})
  })

  validation {
    condition     = lookup(var.workspace, "location", null) != null || var.location != null
    error_message = "location must be set on var.workspace.location or on the module-level var.location."
  }

  validation {
    condition     = lookup(var.workspace, "resource_group_name", null) != null || var.resource_group_name != null
    error_message = "resource_group_name must be set on var.workspace.resource_group_name or on the module-level var.resource_group_name."
  }
}

variable "location" {
  description = "default azure region to be used."
  type        = string
  default     = null
}

variable "resource_group_name" {
  description = "default resource group to be used."
  type        = string
  default     = null
}

variable "tags" {
  description = "default tags to be used."
  type        = map(string)
  default     = {}
}
