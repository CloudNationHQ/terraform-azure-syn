module "naming" {
  source  = "cloudnationhq/naming/azure"
  version = "~> 0.26"

  suffix = ["demo", "dev"]
}

module "rg" {
  source  = "cloudnationhq/rg/azure"
  version = "~> 3.0"

  groups = {
    syn = {
      name     = module.naming.resource_group.name_unique
      location = "germanywestcentral"
    }
  }
}

module "network" {
  source  = "cloudnationhq/vnet/azure"
  version = "~> 10.0"

  vnet = {
    name                = module.naming.virtual_network.name
    location            = module.rg.groups.syn.location
    resource_group_name = module.rg.groups.syn.name
    address_space       = ["10.19.0.0/16"]

    subnets = {
      sn1 = {
        network_security_group = {}
        address_prefixes       = ["10.19.1.0/24"]
      }
    }
  }
}

module "private_dns" {
  source  = "cloudnationhq/pdns/azure"
  version = "~> 5.0"

  resource_group_name = module.rg.groups.syn.name

  zones = {
    private = {
      dev = {
        name = "privatelink.dev.azuresynapse.net"
        virtual_network_links = {
          link1 = {
            virtual_network_id   = module.network.vnet.id
            registration_enabled = true
          }
        }
      }
    }
  }
}

module "storage" {
  source  = "cloudnationhq/sa/azure"
  version = "~> 5.0"

  storage = {
    name                = module.naming.storage_account.name_unique
    location            = module.rg.groups.syn.location
    resource_group_name = module.rg.groups.syn.name
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
  version = "~> 6.0"

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
  version = "~> 3.0"

  workspace = {
    name                                 = module.naming.synapse_workspace.name_unique
    storage_data_lake_gen2_filesystem_id = module.storage.file_systems.adls-gen2.id
    location                             = module.rg.groups.syn.location
    resource_group_name                  = module.rg.groups.syn.name
    sql_administrator_login              = "sqladminuser"
    sql_administrator_login_password     = module.kv.secrets.synapse-admin-password.value
    public_network_access_enabled        = false
    managed_virtual_network_enabled      = true

    identity = {
      type = "SystemAssigned"
    }

    private_endpoints = {
      dev = {
        name                          = module.naming.private_endpoint.name
        subnet_resource_id            = module.network.subnets.sn1.id
        subresource_name              = "Dev"
        private_dns_zone_resource_ids = [module.private_dns.private_zones.dev.id]
      }
    }
  }
}
