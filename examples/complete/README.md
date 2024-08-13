This example highlights the complete usage.

## Remark

This example uses a data block to grab the public IP that is used run the terraform apply. This is needed for the linked_service to be created. Do not use this in a customer environment, it is solely to provide a working example.

## Usage

```hcl
module "synapse" {
  source  = "cloudnationhq/synapse/azure"
  version = "~> 0.4"

  naming = local.naming

  workspace = {
    name                             = "complete-synapse-example"
    storage_account_id               = module.storage.account.id
    location                         = module.rg.groups.syn.location
    resource_group                    = module.rg.groups.syn.name
    sql_administrator_login          = "sqladminuser"
    sql_administrator_login_password = module.kv.secrets.synapse-admin-password.value
    compute_subnet_id                = module.network.subnets.sn1.id

    aad_admin = {
      login = "AzureAD Admin"
    }

    firewall_rule = {
      firewall_rule1 = {
        start_ip_address = "10.0.0.0"
        end_ip_address   = "10.0.0.1"
      }
      firewall_rule2 = {
        start_ip_address = "172.12.0.1"
        end_ip_address   = "172.12.0.10"
      }
    }

    sql_pool = {
      pool1 = {
        name           = "pool1"
        sku_name       = "DW100c"
        data_encrypted = true
      }
    }

    integration_runtime_azure = {
      ira1 = {
        name = "azure-hosted-ir"
      }
    }

    integration_runtime_self_hosted = {
      irs1 = {
        name = "self-hosted-ir"
      }
    }
  }
}
```