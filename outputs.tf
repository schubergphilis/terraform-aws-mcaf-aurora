output "id" {
  value       = aws_rds_cluster.default.id
  description = "ID of the Aurora cluster"
}

output "endpoint" {
  value       = aws_rds_cluster.default.endpoint
  description = "The DNS address of the RDS instance"
}

output "reader_endpoint" {
  value       = aws_rds_cluster.default.reader_endpoint
  description = "A read-only endpoint for the Aurora cluster, automatically load-balanced across replicas"
}

output "port" {
  value       = aws_rds_cluster.default.port
  description = "The database port"
}
