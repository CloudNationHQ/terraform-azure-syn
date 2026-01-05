locals {
  naming = {
    # lookup outputs to have consistent naming
    for type in local.naming_types : type => lookup(module.naming, type).name
  }

  naming_types = [
    "key_vault_secret",
    "key_vault_key",
    "user_assigned_identity",
    "synapse_workspace",
    "storage_data_lake_gen2_filesystem",
  ]
}
