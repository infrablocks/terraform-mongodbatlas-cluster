module "cluster" {
  source = "./../../"

  component             = var.component
  deployment_identifier = var.deployment_identifier

  project_id = module.project.project_id

  cluster_type = "REPLICASET"
  mongo_db_major_version = "6.0"
  disk_size_gb = 100
  number_of_shards = 1

  cloud_provider = {
    name: "AWS"
    region_name: "EU_WEST_1"
    instance_size_name: "M30"
    disk_iops: 3000
    volume_type: "STANDARD"
    backup_enabled: true
    auto_scaling: {
      compute: {
        min_instance_size : "M30"
        max_instance_size : "M40"
      }
    }
  }

  auto_scaling = {
    disk_gb: {
      enabled: true
    }
    compute: {
      enabled: true
      scale_down_enabled: true
    }
  }

  database_users = [
    {
      username: "user-1"
      password: "password-1"
      roles: [
        {
          role_name: "readAnyDatabase"
          database_name: "admin"
          collection_name: ""
        },
        {
          role_name: "readWrite"
          database_name: "specific"
          collection_name: "things"
        }
      ]
      labels: {
        important: "thing"
        something: "else"
      }
    },
    {
      username: "user-2"
      password: "password-2"
      roles: [
        {
          role_name: "dbAdmin"
          database_name: "specific"
          collection_name: ""
        }
      ]
      labels: {}
    }
  ]

  labels = {
    top: "level"
  }
}
