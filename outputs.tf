output "id" {
  value       = aws_rds_cluster.default.id
  description = "ID of the Aurora cluster"
}

output "arn" {
  value       = aws_rds_cluster.default.arn
  description = "ARN of the Aurora cluster"
}

output "database" {
  value       = var.database
  description = "Name of the first database created when the cluster was created"
}

output "username" {
  value       = var.username
  description = "Username for the master DB user"
}

output "endpoint" {
  value       = aws_rds_cluster.default.endpoint
  description = "DNS address of the RDS instance"
}

output "port" {
  value       = aws_rds_cluster.default.port
  description = "Port on which the DB accepts connections"
}

output "reader_endpoint" {
  value       = aws_rds_cluster.default.reader_endpoint
  description = "A load-balanced read-only endpoint for the Aurora cluster"
}

output "security_group_id" {
  value       = aws_security_group.default.id
  description = "The securitiry group id that is attached to the Aurora cluster"
}
