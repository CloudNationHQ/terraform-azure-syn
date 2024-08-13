locals {
  pools = {
    analytics = {
      name                      = "sysqlanalytics"
      sku_name                  = "DW100c"
      data_encrypted            = true
      geo_backup_policy_enabled = true
      storage_account_type      = "GRS"
    },
    datamart = {
      name                      = "sysqldatamart"
      sku_name                  = "DW200c"
      collation                 = "SQL_Latin1_General_CP1_CI_AS"
      geo_backup_policy_enabled = false
      storage_account_type      = "LRS"
    }
  }
}
