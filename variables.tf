variable "component" {
  description = "The component this project will contain."
  type        = string
}
variable "deployment_identifier" {
  description = "An identifier for this instantiation."
  type        = string
}

variable "project_id" {
  type        = string
  description = "The ID of the project within which to create the cluster."
}

variable "cluster_type" {
  type = string
  description = "The type of cluster to create. One of [\"REPLICASET\", \"SHARDED\", \"GEOSHARDED\"]."
  default = "REPLICASET"
}

variable "provider_name" {
  type = string
  description = "The provider to use for the cluster. One of [\"AWS\", \"GCP\", \"AZURE\", \"TENANT\"]."
}

variable "provider_region_name" {
  type = string
  description = "The Atlas region of the provider in which the cluster should be created. Provider specific, see https://docs.atlas.mongodb.com/reference for details."
}

variable "provider_instance_size" {
  type = string
  description = "The instance size to use for the cluster. Provider specific, see https://docs.atlas.mongodb.com/reference for details."
}

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
  description = "A list of database users to create for the cluster"
  default     = []
}
