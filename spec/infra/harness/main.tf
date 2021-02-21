data "terraform_remote_state" "prerequisites" {
  backend = "local"

  config = {
    path = "${path.module}/../../../../state/prerequisites.tfstate"
  }
}

module "cluster" {
  source = "../../../../"

  component             = var.component
  deployment_identifier = var.deployment_identifier

  project_id = data.terraform_remote_state.prerequisites.outputs.project_id

  cluster_type = var.cluster_type

  provider_name = var.provider_name
  provider_region_name = var.provider_region_name
  provider_instance_size = var.provider_instance_size

  database_users = var.database_users
}
