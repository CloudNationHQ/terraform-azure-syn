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
  vault  = local.vault
}

module "network" {
  source  = "cloudnationhq/vnet/azure"
  version = "~> 2.0"

  naming = local.naming

  vnet = {
    name          = module.naming.virtual_network.name
    location      = module.rg.groups.demo.location
    resourcegroup = module.rg.groups.demo.name
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
  source = "../../"

  naming    = local.naming
  workspace = local.workspace
}
