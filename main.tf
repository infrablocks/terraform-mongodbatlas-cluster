locals {
  database_users = {
  for database_user in var.database_users:
  database_user.username => database_user
  }
}

resource "mongodbatlas_cluster" "cluster" {
  project_id = var.project_id
  name       = "${var.component}-${var.deployment_identifier}"

  cluster_type = var.cluster_type

  provider_name               = var.provider_name
  provider_region_name        = var.provider_region_name
  provider_instance_size_name = var.provider_instance_size

  replication_specs {
    num_shards = 1

    regions_config {
      region_name     = var.provider_region_name
      electable_nodes = 3
      priority        = 7
    }
  }
}

resource "mongodbatlas_database_user" "user" {
  for_each = local.database_users

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
    for_each = each.value.labels
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
