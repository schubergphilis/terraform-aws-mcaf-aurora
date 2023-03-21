# terraform-aws-mcaf-aurora

Terraform module to create an AWS RDS Aurora cluster.

IMPORTANT: We do not pin modules to versions in our examples. We highly recommend that in your code you pin the version to the exact version you are using so that your infrastructure remains stable.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.12.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.12.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_rds_enhanced_monitoring_role"></a> [rds\_enhanced\_monitoring\_role](#module\_rds\_enhanced\_monitoring\_role) | github.com/schubergphilis/terraform-aws-mcaf-role | v0.3.3 |

## Resources

| Name | Type |
|------|------|
| [aws_db_parameter_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_parameter_group) | resource |
| [aws_db_subnet_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_rds_cluster.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster) | resource |
| [aws_rds_cluster_instance.cluster_instances](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster_instance) | resource |
| [aws_rds_cluster_parameter_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/rds_cluster_parameter_group) | resource |
| [aws_security_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.ingress_cidrs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ingress_groups](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_subnet.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_password"></a> [password](#input\_password) | Password for the master DB user | `string` | n/a | yes |
| <a name="input_stack"></a> [stack](#input\_stack) | The stack name for the Aurora Cluster | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnet IDs to deploy Aurora in | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the bucket | `map(string)` | n/a | yes |
| <a name="input_username"></a> [username](#input\_username) | Username for the master DB user | `string` | n/a | yes |
| <a name="input_allow_major_version_upgrade"></a> [allow\_major\_version\_upgrade](#input\_allow\_major\_version\_upgrade) | Enable to allow major engine version upgrades when changing engine versions | `bool` | `false` | no |
| <a name="input_apply_immediately"></a> [apply\_immediately](#input\_apply\_immediately) | Specifies whether any cluster modifications are applied immediately | `bool` | `true` | no |
| <a name="input_auto_minor_version_upgrade"></a> [auto\_minor\_version\_upgrade](#input\_auto\_minor\_version\_upgrade) | Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window | `bool` | `true` | no |
| <a name="input_auto_pause"></a> [auto\_pause](#input\_auto\_pause) | Whether to enable automatic pause | `bool` | `true` | no |
| <a name="input_backup_retention_period"></a> [backup\_retention\_period](#input\_backup\_retention\_period) | The days to retain backups for | `number` | `7` | no |
| <a name="input_cidr_blocks"></a> [cidr\_blocks](#input\_cidr\_blocks) | List of CIDR blocks that should be allowed access to the Aurora cluster | `list(string)` | `null` | no |
| <a name="input_cluster_family"></a> [cluster\_family](#input\_cluster\_family) | The family of the DB cluster parameter group | `string` | `"aurora-mysql5.7"` | no |
| <a name="input_cluster_parameters"></a> [cluster\_parameters](#input\_cluster\_parameters) | A list of cluster DB parameters to apply | <pre>list(object({<br>    apply_method = optional(string, "immediate")<br>    name         = string<br>    value        = string<br>  }))</pre> | <pre>[<br>  {<br>    "name": "character_set_server",<br>    "value": "utf8"<br>  },<br>  {<br>    "name": "character_set_client",<br>    "value": "utf8"<br>  }<br>]</pre> | no |
| <a name="input_database"></a> [database](#input\_database) | The name of the first database to be created when the cluster is created | `string` | `null` | no |
| <a name="input_database_parameters"></a> [database\_parameters](#input\_database\_parameters) | A list of instance DB parameters to apply | <pre>list(object({<br>    apply_method = optional(string, "immediate")<br>    name         = string<br>    value        = string<br>  }))</pre> | `null` | no |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | A boolean indicating if the DB instance should have deletion protection enable | `bool` | `true` | no |
| <a name="input_enable_http_endpoint"></a> [enable\_http\_endpoint](#input\_enable\_http\_endpoint) | Enable Aurora Serverless HTTP endpoint (Data API) | `bool` | `false` | no |
| <a name="input_enabled_cloudwatch_logs_exports"></a> [enabled\_cloudwatch\_logs\_exports](#input\_enabled\_cloudwatch\_logs\_exports) | List of log types to export to cloudwatch | `list(string)` | `null` | no |
| <a name="input_engine"></a> [engine](#input\_engine) | The engine type of the Aurora cluster | `string` | `"aurora-mysql"` | no |
| <a name="input_engine_mode"></a> [engine\_mode](#input\_engine\_mode) | The engine mode of the Aurora cluster | `string` | `"serverless"` | no |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | The engine version of the Aurora cluster | `string` | `"5.7.mysql_aurora.2.08.3"` | no |
| <a name="input_final_snapshot_identifier"></a> [final\_snapshot\_identifier](#input\_final\_snapshot\_identifier) | Identifier of the final snapshot to create before deleting the cluster | `string` | `null` | no |
| <a name="input_iam_database_authentication_enabled"></a> [iam\_database\_authentication\_enabled](#input\_iam\_database\_authentication\_enabled) | Specify if mapping AWS IAM accounts to database accounts is enabled. | `bool` | `null` | no |
| <a name="input_iam_roles"></a> [iam\_roles](#input\_iam\_roles) | A list of IAM Role ARNs to associate with the cluster | `list(string)` | `null` | no |
| <a name="input_instance_class"></a> [instance\_class](#input\_instance\_class) | The class of RDS instances to attach. Only for serverless engine\_mode | `string` | `"db.r5.large"` | no |
| <a name="input_instance_count"></a> [instance\_count](#input\_instance\_count) | The number of RDS instances to attach. Only for serverless engine\_mode | `number` | `1` | no |
| <a name="input_kms_key_id"></a> [kms\_key\_id](#input\_kms\_key\_id) | The KMS key ID used for the storage encryption | `string` | `null` | no |
| <a name="input_max_capacity"></a> [max\_capacity](#input\_max\_capacity) | The maximum capacity of the serverless cluster | `string` | `8` | no |
| <a name="input_min_capacity"></a> [min\_capacity](#input\_min\_capacity) | The minimum capacity of the serverless cluster | `string` | `1` | no |
| <a name="input_monitoring_interval"></a> [monitoring\_interval](#input\_monitoring\_interval) | The interval (seconds) for collecting enhanced monitoring metrics | `string` | `null` | no |
| <a name="input_performance_insights"></a> [performance\_insights](#input\_performance\_insights) | Specifies whether Performance Insights is enabled or not | `bool` | `false` | no |
| <a name="input_performance_insights_retention_period"></a> [performance\_insights\_retention\_period](#input\_performance\_insights\_retention\_period) | Amount of time in days to retain Performance Insights data. Valida values are 7, 731 (2 years) or a multiple of 31. When specifying performance\_insights\_retention\_period, performance\_insights needs to be set to true | `number` | `7` | no |
| <a name="input_permissions_boundary"></a> [permissions\_boundary](#input\_permissions\_boundary) | The ARN of the policy that is used to set the permissions boundary for the role | `string` | `null` | no |
| <a name="input_preferred_backup_window"></a> [preferred\_backup\_window](#input\_preferred\_backup\_window) | The daily time range during which automated backups are created, in UTC e.g. 04:00-09:00 | `string` | `null` | no |
| <a name="input_preferred_maintenance_window"></a> [preferred\_maintenance\_window](#input\_preferred\_maintenance\_window) | The weekly time range during which system maintenance can occur, in UTC e.g. wed:04:00-wed:04:30 | `string` | `null` | no |
| <a name="input_publicly_accessible"></a> [publicly\_accessible](#input\_publicly\_accessible) | Control if instances in cluster are publicly accessible | `string` | `false` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | List of security group IDs allowed to connect to Aurora | `list(string)` | `[]` | no |
| <a name="input_snapshot_identifier"></a> [snapshot\_identifier](#input\_snapshot\_identifier) | Database snapshot identifier to create the database from | `string` | `null` | no |
| <a name="input_storage_encrypted"></a> [storage\_encrypted](#input\_storage\_encrypted) | Specifies whether the DB cluster is encrypted | `bool` | `true` | no |
| <a name="input_timeout_action"></a> [timeout\_action](#input\_timeout\_action) | The action to take when the timeout is reached | `string` | `"RollbackCapacityChange"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | ARN of the Aurora cluster |
| <a name="output_cluster_identifier"></a> [cluster\_identifier](#output\_cluster\_identifier) | The RDS Cluster Identifier |
| <a name="output_cluster_resource_id"></a> [cluster\_resource\_id](#output\_cluster\_resource\_id) | The RDS Cluster Resource ID |
| <a name="output_database"></a> [database](#output\_database) | Name of the first database created when the cluster was created |
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | DNS address of the RDS instance |
| <a name="output_id"></a> [id](#output\_id) | ID of the Aurora cluster |
| <a name="output_instance_ids"></a> [instance\_ids](#output\_instance\_ids) | ID's of RDS Aurora instances |
| <a name="output_port"></a> [port](#output\_port) | Port on which the DB accepts connections |
| <a name="output_reader_endpoint"></a> [reader\_endpoint](#output\_reader\_endpoint) | A load-balanced read-only endpoint for the Aurora cluster |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | The securitiry group id that is attached to the Aurora cluster |
| <a name="output_username"></a> [username](#output\_username) | Username for the master DB user |
<!-- END_TF_DOCS -->

## Licensing

100% Open Source and licensed under the Apache License Version 2.0. See [LICENSE](https://github.com/schubergphilis/terraform-aws-mcaf-aurora/blob/master/LICENSE) for full details.
