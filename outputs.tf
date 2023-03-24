output "arn" {
  value       = aws_rds_cluster.default.arn
  description = "ARN of the Aurora cluster"
}

output "cluster_identifier" {
  value       = aws_rds_cluster.default.cluster_identifier
  description = "The RDS Cluster Identifier"
}

output "cluster_resource_id" {
  value       = aws_rds_cluster.default.cluster_resource_id
  description = "The RDS Cluster Resource ID"
}

output "database" {
  value       = var.database
  description = "Name of the first database created when the cluster was created"
}

output "endpoint" {
  value       = aws_rds_cluster.default.endpoint
  description = "DNS address of the RDS instance"
}

output "id" {
  value       = aws_rds_cluster.default.id
  description = "ID of the Aurora cluster"
}

output "instance_ids" {
  value       = merge({ for k, v in aws_rds_cluster_instance.first : k => v.id }, { for k, v in aws_rds_cluster_instance.rest : k => v.id })
  description = "Aurora instances IDs"
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

output "username" {
  value       = var.username
  description = "Username for the master DB user"
}
