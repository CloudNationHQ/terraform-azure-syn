locals {
  workspace = {
    name                             = "complete-synapse-example"
    storage_account_id               = module.storage.account.id
    location                         = module.rg.groups.demo.location
    resourcegroup                    = module.rg.groups.demo.name
    sql_administrator_login          = "sqladminuser"
    sql_administrator_login_password = module.kv.secrets.synapse-admin-password.value
    compute_subnet_id                = module.network.subnets.sn1.id
    managed_resource_group_name      = "${module.rg.groups.demo.name}-synapse-resources"
    managed_virtual_network_enabled  = true

    identity = {
      type = "SystemAssigned, UserAssigned"
    }

    workspace_key = {
      key_versionless_id = module.kv.keys.workspace-encryption-key.resource_versionless_id
      key_name           = module.kv.keys.workspace-encryption-key.name
    }

    aad_admin = {
      login = "AzureAD Admin"
    }

    firewall_rule = {
      local_ip = {
        start_ip_address = chomp(data.http.current_public_ip.response_body)
        end_ip_address   = chomp(data.http.current_public_ip.response_body)
      }
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

    spark_pool = {
      pool1 = {
        name                                = "pool1"
        node_size_family                    = "MemoryOptimized"
        node_size                           = "Small"
        dynamic_executor_allocation_enabled = true
        min_executors                       = 1
        max_executors                       = 3
        spark_version                       = "3.3"
        auto_scale = {
          min_node_count = 3
          max_node_count = 5
        }

        auto_pause = {
          delay_in_minutes = 15
        }
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

    linked_service = {
      ls1 = {
        name                 = "ls1"
        type                 = "AzureBlobStorage"
        type_properties_json = <<JSON
{
  "connectionString": "DefaultEndpointsProtocol=https;AccountName=storagesample;AccountKey=1234567890"
}
JSON
        integration_runtime = {
          name = "azure-hosted-ir"
        }
      }
    }
  }
}
