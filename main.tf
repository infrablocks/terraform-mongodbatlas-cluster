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
