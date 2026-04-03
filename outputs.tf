output "workspace" {
  description = "contains all synapse workspace configuration"
  value       = azurerm_synapse_workspace.synapse_workspace
}

output "sql_pools" {
  description = "contains all synapse sql pool configuration"
  value       = azurerm_synapse_sql_pool.synapse_sql_pool
}

output "spark_pools" {
  description = "contains all synapse spark pool configuration"
  value       = azurerm_synapse_spark_pool.synapse_spark_pool
}

output "aad_admin" {
  description = "contains all synapse workspace aad admin configuration"
  value       = azurerm_synapse_workspace_aad_admin.synapse_workspace
}

output "firewall_rules" {
  description = "contains all synapse firewall rule configuration"
  value       = azurerm_synapse_firewall_rule.synapse_firewall_rule
}

output "role_assignments" {
  description = "contains all synapse role assignment configuration"
  value       = azurerm_synapse_role_assignment.synapse_role_assignment
}

output "managed_private_endpoints" {
  description = "contains all synapse managed private endpoint configuration"
  value       = azurerm_synapse_managed_private_endpoint.synapse_managed_private_endpoint
}

output "integration_runtime_self_hosted" {
  description = "contains all synapse integration runtime self hosted configuration"
  value       = azurerm_synapse_integration_runtime_self_hosted.synapse_irsh
}

output "integration_runtime_azure" {
  description = "contains all synapse integration runtime azure configuration"
  value       = azurerm_synapse_integration_runtime_azure.synapse_ira
}

output "linked_services" {
  description = "contains all synapse linked service configuration"
  value       = azurerm_synapse_linked_service.synapse_linked_service
}

output "workspace_keys" {
  description = "contains all synapse workspace key configuration"
  value       = azurerm_synapse_workspace_key.workspace_key
}
