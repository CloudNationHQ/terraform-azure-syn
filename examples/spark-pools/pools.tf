locals {
  pools = {
    core = {
      name                                = "syspcore"
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
    analytics = {
      name                                = "syspanalytics"
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
}
