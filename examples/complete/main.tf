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
      adls-gen2 = {
        name = module.naming.storage_data_lake_gen2_filesystem.name
      }
    }
  }
}

module "kv" {
  source  = "cloudnationhq/kv/azure"
  version = "~> 0.1"

  naming = local.naming
  vault  = local.vault
}

module "network" {
  source  = "cloudnationhq/vnet/azure"
  version = "~> 2.0"

  naming = local.naming

  vnet = {
    name          = module.naming.virtual_network.name
    location      = module.rg.groups.syn.location
    resourcegroup = module.rg.groups.syn.name
    cidr          = ["10.0.0.0/16"]
    subnets = {
      sn1 = {
        cidr = ["10.0.0.0/24"]
        nsg  = {}
      }
    }
  }
}


module "synapse" {
  source  = "cloudnationhq/syn/azure"
  version = "~> 0.1"

  naming    = local.naming
  workspace = local.workspace
}
