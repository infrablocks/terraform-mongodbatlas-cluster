locals {
  # default for cases when `null` value provided, meaning "use default"
  cluster_type           = var.cluster_type == null ? "REPLICASET" : var.cluster_type
  mongo_db_major_version = var.mongo_db_major_version == null ? "4.4" : var.mongo_db_major_version
  number_of_shards       = var.number_of_shards == null ? 1 : var.number_of_shards

  auto_scaling = var.auto_scaling == null ? {
    disk_gb : {
      enabled : true,
    },
    compute : {
      enabled : false,
      scale_down_enabled : false
    }
  } : var.auto_scaling

  database_users = var.database_users == null ? [] : var.database_users

  labels = var.labels == null ? {} : var.labels
}