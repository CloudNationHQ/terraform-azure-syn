locals {
  vault = {
    name          = module.naming.key_vault.name_unique
    location      = module.rg.groups.demo.location
    resourcegroup = module.rg.groups.demo.name
    secrets = {
      random_string = {
        synapse-admin-password = {
          length      = 24
          special     = true
          min_special = 2
          min_upper   = 2
        }
      }
    }
    keys = {
      workspace-encryption-key = {
        key_type = "RSA"
        key_size = 2048
        key_opts = [
          "sign", "unwrapKey",
          "verify", "wrapKey"
        ]
      }
    }
  }
}