moved {
  from = azurerm_synapse_workspace.synapse_workspace
  to   = azurerm_synapse_workspace.this
}

moved {
  from = azurerm_synapse_workspace_aad_admin.synapse_workspace["default"]
  to   = azurerm_synapse_workspace_aad_admin.this["this"]
}

moved {
  from = azurerm_synapse_firewall_rule.synapse_firewall_rule
  to   = azurerm_synapse_firewall_rule.this
}

moved {
  from = azurerm_synapse_sql_pool.synapse_sql_pool
  to   = azurerm_synapse_sql_pool.this
}

moved {
  from = azurerm_synapse_spark_pool.synapse_spark_pool
  to   = azurerm_synapse_spark_pool.this
}

moved {
  from = azurerm_synapse_role_assignment.synapse_role_assignment
  to   = azurerm_synapse_role_assignment.this
}

moved {
  from = azurerm_synapse_managed_private_endpoint.synapse_managed_private_endpoint
  to   = azurerm_synapse_managed_private_endpoint.this
}

moved {
  from = azurerm_synapse_integration_runtime_self_hosted.synapse_irsh
  to   = azurerm_synapse_integration_runtime_self_hosted.this
}

moved {
  from = azurerm_synapse_integration_runtime_azure.synapse_ira
  to   = azurerm_synapse_integration_runtime_azure.this
}

moved {
  from = azurerm_synapse_linked_service.synapse_linked_service
  to   = azurerm_synapse_linked_service.this
}

moved {
  from = azurerm_synapse_workspace_key.workspace_key["default"]
  to   = azurerm_synapse_workspace_key.this["this"]
}
