variable "component" {}
variable "deployment_identifier" {}

variable "cluster_type" {}

variable "provider_name" {}
variable "provider_region_name" {}
variable "provider_instance_size" {}

variable "database_users" {
  type = list(object({
    username: string,
    password: string,
    roles: list(object({
      role_name: string,
      database_name: string,
      collection_name: string
    })),
    labels: map(string)
  }))
}
