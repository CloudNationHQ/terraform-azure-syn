This example highlights the default usage.

## Usage

module "synapse" {
  source  = "cloudnationhq/synapse/azure"
  version = "~> 0.1"

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