locals {
  naming = {
    # lookup outputs to have consistent naming
    for type in local.naming_types : type => lookup(module.naming, type).name
  }

  naming_types = [
    "key_vault_secret",
    "synapse_workspace",
    "synapse_integration_runtime_azure",
    "synapse_integration_runtime_self_hosted",
    "storage_data_lake_gen2_filesystem",
  ]
}
