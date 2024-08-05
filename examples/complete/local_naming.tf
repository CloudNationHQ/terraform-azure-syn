locals {
  naming = {
    # lookup outputs to have consistent naming
    for type in local.naming_types : type => lookup(module.naming, type).name
  }

  naming_types = ["key_vault_secret", "key_vault_key", "user_assigned_identity", "resource_group", "storage_account", "subnet", "network_security_group"]
}