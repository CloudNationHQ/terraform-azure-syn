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
