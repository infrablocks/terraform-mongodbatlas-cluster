variable "component" {}
variable "deployment_identifier" {}

variable "cluster_type" {
  default = null
}

variable "mongo_db_major_version" {
  default = null
}

variable "disk_size_gb" {
  type    = number
  default = null
}

variable "number_of_shards" {
  type    = number
  default = null
}

variable "auto_scaling" {
  type = object({
    disk_gb : object({
      enabled : bool
    }),
    compute : object({
      enabled : bool,
      scale_down_enabled : bool
    })
  })
  default = null
}

variable "cloud_provider" {
  type = object({
    name : string,
    region_name : string,
    instance_size_name : string
    disk_iops : number,
    volume_type : string,
    backup_enabled : bool,
    auto_scaling = object({
      compute : object({
        min_instance_size : string,
        max_instance_size : string,
      })
    })
  })
}

variable "database_users" {
  type = list(object({
    username : string,
    password : string,
    roles : list(object({
      role_name : string,
      database_name : string,
      collection_name : string
    })),
    labels : map(string)
  }))
  default = null
}

variable "labels" {
  type    = map(string)
  default = null
}