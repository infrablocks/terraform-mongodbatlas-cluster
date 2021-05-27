data "terraform_remote_state" "prerequisites" {
  backend = "local"

  config = {
    path = "${path.module}/../../../../state/prerequisites.tfstate"
  }
}

module "cluster" {
  # This makes absolutely no sense. I think there's a bug in terraform.
  source = "./../../../../../../../"

  component             = var.component
  deployment_identifier = var.deployment_identifier

  project_id = data.terraform_remote_state.prerequisites.outputs.project_id

  cluster_type = var.cluster_type

  mongo_db_major_version = var.mongo_db_major_version

  disk_size_gb = var.disk_size_gb

  number_of_shards = var.number_of_shards

  auto_scaling = var.auto_scaling
  cloud_provider = var.cloud_provider
  database_users = var.database_users
}
