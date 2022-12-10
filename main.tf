locals {
  database_users_map = {
    for database_user in local.database_users:
      database_user.username => database_user
  }
}

resource "mongodbatlas_cluster" "cluster" {
  project_id = var.project_id
  name       = "${var.component}-${var.deployment_identifier}"

  cluster_type = local.cluster_type

  mongo_db_major_version = local.mongo_db_major_version

  disk_size_gb = var.disk_size_gb

  auto_scaling_disk_gb_enabled            = local.auto_scaling.disk_gb.enabled
  auto_scaling_compute_enabled            = local.auto_scaling.compute.enabled
  auto_scaling_compute_scale_down_enabled = local.auto_scaling.compute.scale_down_enabled

  provider_name                                   = var.cloud_provider.name
  provider_region_name                            = var.cloud_provider.region_name
  provider_instance_size_name                     = var.cloud_provider.instance_size_name
  provider_disk_iops                              = var.cloud_provider.disk_iops
  provider_volume_type                            = var.cloud_provider.volume_type
  provider_backup_enabled                         = var.cloud_provider.backup_enabled
  provider_auto_scaling_compute_min_instance_size = var.cloud_provider.auto_scaling.compute.min_instance_size
  provider_auto_scaling_compute_max_instance_size = var.cloud_provider.auto_scaling.compute.max_instance_size

  replication_specs {
    num_shards = local.number_of_shards

    regions_config {
      region_name     = var.cloud_provider.region_name
      electable_nodes = 3
      priority        = 7
    }
  }

  // TODO: we need to ignore changes of provider_instance_size_name when compute
  //       auto scaling is enabled but not when it's not; terraform is yet to
  //       support this https://github.com/hashicorp/terraform/issues/3116
}

resource "mongodbatlas_database_user" "user" {
  for_each = local.database_users_map

  project_id         = var.project_id
  username           = each.key
  password           = each.value.password
  auth_database_name = "admin"

  dynamic "roles" {
    for_each = each.value.roles

    content {
      role_name       = roles.value.role_name
      database_name   = roles.value.database_name
      collection_name = roles.value.collection_name
    }
  }

  dynamic "labels" {
    for_each = merge(local.resolved_labels, each.value.labels)
    content {
      key   = labels.key
      value = labels.value
    }
  }

  scopes {
    type = "CLUSTER"
    name = mongodbatlas_cluster.cluster.name
  }
}
