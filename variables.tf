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

variable "mongo_db_major_version" {
  type = string
  description = "The version of MongoDB to deploy to the cluster. One of [\"3.6\", \"4.0\", \"4.2\", \"4.4\"]. If provider_instance_size is \"M2\" or \"M5\", this must be \"4.4\"."
  default = "4.4"
}

variable "disk_size_gb" {
  type = number
  description = "The capacity, in GB, of each cluster instance host's root volume. AWS / GCP only."
  default = null
}

variable "auto_scaling" {
  type = object({
    disk_gb: object({
      enabled: bool
    }),
    compute: object({
      enabled: bool,
      scale_down_enabled: bool
    })
  })
  description = "Auto-scaling configuration for the cluster."
  default = {
    disk_gb: {
      enabled: true,
    },
    compute: {
      enabled: false,
      scale_down_enabled: false
    }
  }
}

variable "cloud_provider" {
  type = object({
    name: string,
    region_name: string,
    instance_size_name: string
    auto_scaling = object({
      compute: object({
        min_instance_size: string,
        max_instance_size: string,
      })
    })
  })
  description = "Cloud provider configuration for the cluster."
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
