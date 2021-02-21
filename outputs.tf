output "cluster_id" {
  value = mongodbatlas_cluster.cluster.cluster_id
}

output "connection_strings" {
  value = mongodbatlas_cluster.cluster.connection_strings
}