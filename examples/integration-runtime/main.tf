module "naming" {
  source  = "cloudnationhq/naming/azure"
  version = "~> 0.26"

  suffix = ["demo", "dev"]
}

module "rg" {
  source  = "cloudnationhq/rg/azure"
  version = "~> 2.0"

  groups = {
    syn = {
      name     = module.naming.resource_group.name_unique
      location = "northeurope"
    }
  }
}

module "storage" {
  source  = "cloudnationhq/sa/azure"
  version = "~> 4.0"

  naming = local.naming

  storage = {
    name                = module.naming.storage_account.name_unique
    location            = module.rg.groups.syn.location
    resource_group_name = module.rg.groups.syn.name
    threat_protection   = true
    is_hns_enabled      = true

    file_systems = {
      adls-gen2 = {
        name = module.naming.storage_data_lake_gen2_filesystem.name
      }
    }
  }
}

module "kv" {
  source  = "cloudnationhq/kv/azure"
  version = "~> 4.0"

  naming = local.naming

  vault = {
    name                = module.naming.key_vault.name_unique
    location            = module.rg.groups.syn.location
    resource_group_name = module.rg.groups.syn.name

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
  version = "~> 2.0"

  naming = local.naming

  workspace = {
    name                                 = module.naming.synapse_workspace.name_unique
    storage_data_lake_gen2_filesystem_id = module.storage.file_systems.adls-gen2.id
    location                             = module.rg.groups.syn.location
    resource_group_name                  = module.rg.groups.syn.name
    sql_administrator_login              = "sqladminuser"
    sql_administrator_login_password     = module.kv.secrets.synapse-admin-password.value

    identity = {
      type = "SystemAssigned"
    }

    integration_runtime_azure = {
      ira1 = {
        name = module.naming.synapse_integration_runtime_azure.name
      }
    }

    integration_runtime_self_hosted = {
      irs1 = {
        name = module.naming.synapse_integration_runtime_self_hosted.name
      }
    }
  }
}
