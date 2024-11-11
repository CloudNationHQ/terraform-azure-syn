# Synapse Workspaces

This terraform module streamlines the setup and management of azure synapse workspaces, providing customizable configurations for sql and spark pools, data integration, analytics, and much more.

## Goals

The main objective is to create a more logic data structure, achieved by combining and grouping related resources together in a complex object.

The structure of the module promotes reusability. It's intended to be a repeatable component, simplifying the process of building diverse workloads and platform accelerators consistently.

A primary goal is to utilize keys and values in the object that correspond to the REST API's structure. This enables us to carry out iterations, increasing its practical value as time goes on.

A last key goal is to separate logic from configuration in the module, thereby enhancing its scalability, ease of customization, and manageability.

## Non-Goals

These modules are not intended to be complete, ready-to-use solutions; they are designed as components for creating your own patterns.

They are not tailored for a single use case but are meant to be versatile and applicable to a range of scenarios.

Security standardization is applied at the pattern level, while the modules include default values based on best practices but do not enforce specific security standards.

End-to-end testing is not conducted on these modules, as they are individual components and do not undergo the extensive testing reserved for complete patterns or solutions.

## Features

- Create and manage SQL/Spark pools.
- Configure azure and self-hosted integration runtimes
- Set up managed private endpoints and linked services

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 4.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_synapse_firewall_rule.synapse_firewall_rule](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_firewall_rule) | resource |
| [azurerm_synapse_integration_runtime_azure.synapse_ira](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_integration_runtime_azure) | resource |
| [azurerm_synapse_integration_runtime_self_hosted.synapse_irsh](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_integration_runtime_self_hosted) | resource |
| [azurerm_synapse_linked_service.synapse_linked_service](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_linked_service) | resource |
| [azurerm_synapse_managed_private_endpoint.synapse_managed_private_endpoint](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_managed_private_endpoint) | resource |
| [azurerm_synapse_role_assignment.synapse_role_assignment](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_role_assignment) | resource |
| [azurerm_synapse_spark_pool.synapse_spark_pool](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_spark_pool) | resource |
| [azurerm_synapse_sql_pool.synapse_sql_pool](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_sql_pool) | resource |
| [azurerm_synapse_workspace.synapse_workspace](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_workspace) | resource |
| [azurerm_synapse_workspace_aad_admin.synapse_workspace](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_workspace_aad_admin) | resource |
| [azurerm_synapse_workspace_key.workspace_key](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/synapse_workspace_key) | resource |
| [azurerm_user_assigned_identity.identity](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | default azure region to be used. | `string` | `null` | no |
| <a name="input_naming"></a> [naming](#input\_naming) | contains naming convention | `map(string)` | `{}` | no |
| <a name="input_resource_group"></a> [resource\_group](#input\_resource\_group) | default resource group to be used. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | default tags to be used. | `map(string)` | `{}` | no |
| <a name="input_workspace"></a> [workspace](#input\_workspace) | describes the synapse workspace configuration | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_spark_pools"></a> [spark\_pools](#output\_spark\_pools) | contains all synapse spark pool configuration |
| <a name="output_sql_pools"></a> [sql\_pools](#output\_sql\_pools) | contains all synapse sql pool configuration |
| <a name="output_user_assigned_identities"></a> [user\_assigned\_identities](#output\_user\_assigned\_identities) | contains all user assigned identities configuration |
| <a name="output_workspace"></a> [workspace](#output\_workspace) | contains all synapse workspace configuration |
<!-- END_TF_DOCS -->

## Testing

For more information, please see our testing [guidelines](./TESTING.md)

## Notes

Using a dedicated module, we've developed a naming convention for resources that's based on specific regular expressions for each type, ensuring correct abbreviations and offering flexibility with multiple prefixes and suffixes.

Full examples detailing all usages, along with integrations with dependency modules, are located in the examples directory.

To update the module's documentation run `make doc`

## Authors

Module is maintained by [these awesome contributors](https://github.com/cloudnationhq/terraform-azure-syn/graphs/contributors).

## Contributing

We welcome contributions from the community! Whether it's reporting a bug, suggesting a new feature, or submitting a pull request, your input is highly valued.

For more information, please see our contribution [guidelines](https://github.com/CloudNationHQ/terraform-azure-syn/blob/main/CONTRIBUTING.md).

## License

MIT Licensed. See [LICENSE](https://github.com/cloudnationhq/terraform-azure-syn/blob/main/LICENSE) for full details.

## References

- [Documentation](https://learn.microsoft.com/en-us/azure/synapse-analytics/)
- [Rest Api](https://learn.microsoft.com/en-us/rest/api/synapse/)
- [Rest Api Specs](https://github.com/Azure/azure-rest-api-specs/tree/main/specification/synapse)
