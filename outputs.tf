output "workspace" {
  description = "contains all synapse workspace configuration"
  value       = azurerm_synapse_workspace.this
}

output "sql_pools" {
  description = "contains all synapse sql pool configuration"
  value       = azurerm_synapse_sql_pool.this
}

output "spark_pools" {
  description = "contains all synapse spark pool configuration"
  value       = azurerm_synapse_spark_pool.this
}

output "aad_admin" {
  description = "contains all synapse workspace aad admin configuration"
  value       = azurerm_synapse_workspace_aad_admin.this
}

output "firewall_rules" {
  description = "contains all synapse firewall rule configuration"
  value       = azurerm_synapse_firewall_rule.this
}

output "role_assignments" {
  description = "contains all synapse role assignment configuration"
  value       = azurerm_synapse_role_assignment.this
}

output "managed_private_endpoints" {
  description = "contains all synapse managed private endpoint configuration"
  value       = azurerm_synapse_managed_private_endpoint.this
}

output "integration_runtime_self_hosted" {
  description = "contains all synapse integration runtime self hosted configuration"
  value       = azurerm_synapse_integration_runtime_self_hosted.this
}

output "integration_runtime_azure" {
  description = "contains all synapse integration runtime azure configuration"
  value       = azurerm_synapse_integration_runtime_azure.this
}

output "linked_services" {
  description = "contains all synapse linked service configuration"
  value       = azurerm_synapse_linked_service.this
}

output "workspace_keys" {
  description = "contains all synapse workspace key configuration"
  value       = azurerm_synapse_workspace_key.this
}

output "private_endpoints" {
  description = "contains all synapse workspace private endpoint configuration"
  value       = azurerm_private_endpoint.this
}
