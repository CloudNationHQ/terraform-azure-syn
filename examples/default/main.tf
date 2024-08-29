module "naming" {
  source  = "cloudnationhq/naming/azure"
  version = "~> 0.1"

  suffix = ["demo", "dev"]
}

module "rg" {
  source  = "cloudnationhq/rg/azure"
  version = "~> 0.1"

  groups = {
    syn = {
      name   = module.naming.resource_group.name
      region = "westeurope"
    }
  }
}

module "storage" {
  source  = "cloudnationhq/sa/azure"
  version = "~> 1.0"

  naming = local.naming

  storage = {
    name              = module.naming.storage_account.name_unique
    location          = module.rg.groups.syn.location
    resource_group    = module.rg.groups.syn.name
    threat_protection = true
    is_hns_enabled    = true
    file_systems = {
      adls-gen2 = {}
    }
  }
}

module "kv" {
  source  = "cloudnationhq/kv/azure"
  version = "~> 0.1"

  naming = local.naming

  vault = {
    name          = module.naming.key_vault.name_unique
    location      = module.rg.groups.syn.location
    resourcegroup = module.rg.groups.syn.name
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
  }
}

module "synapse" {
  source  = "cloudnationhq/syn/azure"
  version = "~> 0.1"

  naming = local.naming

  workspace = {
    name                                 = module.naming.synapse_workspace.name
    storage_data_lake_gen2_filesystem_id = module.storage.file_systems.adls-gen2.id
    location                             = module.rg.groups.syn.location
    resource_group                       = module.rg.groups.syn.name
    sql_administrator_login              = "sqladminuser"
    sql_administrator_login_password     = module.kv.secrets.synapse-admin-password.value
  }
}
