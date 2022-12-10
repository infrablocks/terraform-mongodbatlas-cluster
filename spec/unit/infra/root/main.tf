data "terraform_remote_state" "prerequisites" {
  backend = "local"

  config = {
    path = "${path.module}/../../../../state/prerequisites.tfstate"
  }
}

module "cluster" {
  source = "./../../../../"

  component             = var.component
  deployment_identifier = var.deployment_identifier

  project_id = data.terraform_remote_state.prerequisites.outputs.project_id

  cluster_type = var.cluster_type
  mongo_db_major_version = var.mongo_db_major_version
  disk_size_gb = var.disk_size_gb
  number_of_shards = var.number_of_shards

  cloud_provider = var.cloud_provider

  auto_scaling = var.auto_scaling
  database_users = var.database_users

  labels = var.labels
}
