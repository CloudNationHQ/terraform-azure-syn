module "naming" {
  source  = "cloudnationhq/naming/azure"
  version = "~> 0.1"

  suffix = ["jp", "dev"]
}

module "rg" {
  source  = "cloudnationhq/rg/azure"
  version = "~> 0.1"

  groups = {
    demo = {
      name   = module.naming.resource_group.name
      region = "westeurope"
    }
  }
}

module "storage" {
  source  = "cloudnationhq/sa/azure"
  version = "~> 0.1"

  naming = local.naming

  storage = {
    name              = module.naming.storage_account.name_unique
    location          = module.rg.groups.demo.location
    resourcegroup     = module.rg.groups.demo.name
    threat_protection = true
  }
}

module "kv" {
  source  = "cloudnationhq/kv/azure"
  version = "~> 0.1"

  naming = local.naming

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
  }
}

module "synapse" {
  source = "../../"

  naming = local.naming

  workspace = {
    name                             = "default-synapse-example"
    storage_account_id               = module.storage.account.id
    location                         = module.rg.groups.demo.location
    resourcegroup                    = module.rg.groups.demo.name
    sql_administrator_login          = "sqladminuser"
    sql_administrator_login_password = module.kv.secrets.synapse-admin-password.value
  }
}
