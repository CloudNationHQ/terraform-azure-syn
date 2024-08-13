This example highlights the default usage.

## Usage

```hcl
module "synapse" {
  source  = "cloudnationhq/synapse/azure"
  version = "~> 0.5"

  naming = local.naming

  workspace = {
    name                             = "default-synapse-example"
    storage_account_id               = module.storage.account.id
    location                         = module.rg.groups.syn.location
    resource_group                    = module.rg.groups.syn.name
    sql_administrator_login          = "sqladminuser"
    sql_administrator_login_password = module.kv.secrets.synapse-admin-password.value
  }
}
```