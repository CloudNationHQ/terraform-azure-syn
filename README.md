# Synapse Workspace

This terraform module streamlines the setup and management of azure synapse workspaces, providing customizable configurations for sql and spark pools, data integration, analytics, and much more.

## Features

Create and manage Synapse workspaces with SQL and Spark pools

Configurable firewall rules to control workspace access

Customer-managed key (CMK) encryption with managed identities

Managed private endpoints for private connectivity to Azure resources

Linked services with optional integration runtime binding

Utilization of terratest for robust validation

<!-- BEGIN_TF_DOCS -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~> 1.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 4.0)

## Providers

The following providers are used by this module:

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (~> 4.0)

## Resources

The following resources are used by this module:

- [azurerm_synapse_firewall_rule.synapse_firewall_rule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_firewall_rule) (resource)
- [azurerm_synapse_integration_runtime_azure.synapse_ira](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_integration_runtime_azure) (resource)
- [azurerm_synapse_integration_runtime_self_hosted.synapse_irsh](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_integration_runtime_self_hosted) (resource)
- [azurerm_synapse_linked_service.synapse_linked_service](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_linked_service) (resource)
- [azurerm_synapse_managed_private_endpoint.synapse_managed_private_endpoint](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_managed_private_endpoint) (resource)
- [azurerm_synapse_role_assignment.synapse_role_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_role_assignment) (resource)
- [azurerm_synapse_spark_pool.synapse_spark_pool](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_spark_pool) (resource)
- [azurerm_synapse_sql_pool.synapse_sql_pool](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_sql_pool) (resource)
- [azurerm_synapse_workspace.synapse_workspace](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_workspace) (resource)
- [azurerm_synapse_workspace_aad_admin.synapse_workspace](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_workspace_aad_admin) (resource)
- [azurerm_synapse_workspace_key.workspace_key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_workspace_key) (resource)
- [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) (data source)

## Required Inputs

The following input variables are required:

### <a name="input_workspace"></a> [workspace](#input\_workspace)

Description: describes the synapse workspace configuration

Type:

```hcl
object({
    name                                 = string
    resource_group_name                  = optional(string)
    location                             = optional(string)
    storage_data_lake_gen2_filesystem_id = string
    sql_administrator_login              = optional(string, "sqladminuser")
    sql_administrator_login_password     = string
    azuread_authentication_only          = optional(bool, false)
    compute_subnet_id                    = optional(string)
    data_exfiltration_protection_enabled = optional(bool, false)
    linking_allowed_for_aad_tenant_ids   = optional(list(string), [])
    managed_resource_group_name          = optional(string)
    managed_virtual_network_enabled      = optional(bool, false)
    public_network_access_enabled        = optional(bool, true)
    purview_id                           = optional(string)
    sql_identity_control_enabled         = optional(bool, false)
    tags                                 = optional(map(string))
    azure_devops_repo = optional(object({
      account_name    = optional(string)
      branch_name     = string
      last_commit_id  = optional(string)
      project_name    = string
      repository_name = string
      root_folder     = optional(string, "/")
      tenant_id       = optional(string)
    }))
    customer_managed_key = optional(object({
      key_versionless_id        = string
      key_name                  = optional(string)
      user_assigned_identity_id = optional(string)
    }))
    identity = optional(object({
      type         = string
      identity_ids = optional(list(string), [])
      name         = optional(string)
    }))
    github_repo = optional(object({
      account_name    = optional(string)
      branch_name     = optional(string, "main")
      last_commit_id  = optional(string)
      repository_name = string
      root_folder     = optional(string, "/")
      git_url         = optional(string)
    }))
    aad_admin = optional(object({
      login     = string
      object_id = optional(string)
      tenant_id = optional(string)
    }))
    firewall_rule = optional(map(object({
      name             = optional(string)
      start_ip_address = string
      end_ip_address   = string
    })), {})
    sql_pools = optional(map(object({
      name                      = optional(string)
      sku_name                  = string
      create_mode               = optional(string, "Default")
      collation                 = optional(string)
      data_encrypted            = optional(bool)
      recovery_database_id      = optional(string)
      geo_backup_policy_enabled = optional(bool, true)
      storage_account_type      = optional(string, "GRS")
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
      compute_isolation_enabled           = optional(bool, false)
      dynamic_executor_allocation_enabled = optional(bool, false)
      min_executors                       = optional(number)
      max_executors                       = optional(number)
      session_level_packages_enabled      = optional(bool, false)
      spark_log_folder                    = optional(string, "/logs")
      spark_events_folder                 = optional(string, "/events")
      spark_version                       = optional(string, "2.4")
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
      role_name      = string
      principal_id   = string
      principal_type = string
    })), {})
    managed_private_endpoint = optional(map(object({
      name               = optional(string)
      target_resource_id = string
      subresource_name   = string
    })), {})
    integration_runtime_self_hosted = optional(map(object({
      name = optional(string)
    })), {})
    integration_runtime_azure = optional(map(object({
      name     = optional(string)
      location = optional(string)
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
```

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_location"></a> [location](#input\_location)

Description: default azure region to be used.

Type: `string`

Default: `null`

### <a name="input_naming"></a> [naming](#input\_naming)

Description: contains naming convention

Type: `map(string)`

Default: `{}`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: default resource group to be used.

Type: `string`

Default: `null`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: default tags to be used.

Type: `map(string)`

Default: `{}`

## Outputs

The following outputs are exported:

### <a name="output_spark_pools"></a> [spark\_pools](#output\_spark\_pools)

Description: contains all synapse spark pool configuration

### <a name="output_sql_pools"></a> [sql\_pools](#output\_sql\_pools)

Description: contains all synapse sql pool configuration

### <a name="output_workspace"></a> [workspace](#output\_workspace)

Description: contains all synapse workspace configuration
<!-- END_TF_DOCS -->

## Goals

For more information, please see our [goals and non-goals](./GOALS.md).

## Testing

For more information, please see our testing [guidelines](./TESTING.md)

## Notes

Using a dedicated module, we've developed a naming convention for resources that's based on specific regular expressions for each type, ensuring correct abbreviations and offering flexibility with multiple prefixes and suffixes.

Full examples detailing all usages, along with integrations with dependency modules, are located in the examples directory.

To update the module's documentation run `make doc`

## Contributors

We welcome contributions from the community! Whether it's reporting a bug, suggesting a new feature, or submitting a pull request, your input is highly valued.

For more information, please see our contribution [guidelines](./CONTRIBUTING.md). <br><br>

<a href="https://github.com/cloudnationhq/terraform-azure-syn/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=cloudnationhq/terraform-azure-syn" />
</a>

## License

MIT Licensed. See [LICENSE](https://github.com/cloudnationhq/terraform-azure-syn/blob/main/LICENSE) for full details.

## References

- [Documentation](https://learn.microsoft.com/en-us/azure/synapse-analytics/)
- [Rest Api](https://learn.microsoft.com/en-us/rest/api/synapse/)
- [Rest Api Specs](https://github.com/Azure/azure-rest-api-specs/tree/main/specification/synapse)
