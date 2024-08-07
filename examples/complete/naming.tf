locals {
  naming = {
    # lookup outputs to have consistent naming
    for type in local.naming_types : type => lookup(module.naming, type).name
  }

  naming_types = ["key_vault_secret", "key_vault_key", "user_assigned_identity", "resource_group", "storage_account", "subnet", "network_security_group", "synapse_workspace", "synapse_firewall_rule", "synapse_sql_pool", "synapse_spark_pool", "synapse_linked_service", "synapse_integration_runtime_self_hosted", "synapse_integration_runtime_azure", "storage_data_lake_gen2_filesystem"]
}