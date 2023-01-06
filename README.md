# terraform-aws-mcaf-aurora

<!--- BEGIN_TF_DOCS --->
## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.3 |
| aws | >= 4.12.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 4.12.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| password | Password for the master DB user | `string` | n/a | yes |
| stack | The stack name for the Aurora Cluster | `string` | n/a | yes |
| subnet\_ids | List of subnet IDs to deploy Aurora in | `list(string)` | n/a | yes |
| tags | A mapping of tags to assign to the bucket | `map(string)` | n/a | yes |
| username | Username for the master DB user | `string` | n/a | yes |
| apply\_immediately | Specifies whether any cluster modifications are applied immediately | `bool` | `true` | no |
| auto\_pause | Whether to enable automatic pause | `bool` | `true` | no |
| availability\_zones | List of availability zones to deploy Aurora in | `list(string)` | `[]` | no |
| backup\_retention\_period | The days to retain backups for | `number` | `7` | no |
| cidr\_blocks | List of CIDR blocks that should be allowed access to the Aurora cluster | `list(string)` | `null` | no |
| cluster\_family | The family of the DB cluster parameter group | `string` | `"aurora-mysql5.7"` | no |
| cluster\_parameters | A list of cluster DB parameters to apply | <pre>list(object({<br>    apply_method = optional(string, "immediate")<br>    name         = string<br>    value        = string<br>  }))</pre> | <pre>[<br>  {<br>    "name": "character_set_server",<br>    "value": "utf8"<br>  },<br>  {<br>    "name": "character_set_client",<br>    "value": "utf8"<br>  }<br>]</pre> | no |
| database | The name of the first database to be created when the cluster is created | `string` | `null` | no |
| database\_parameters | A list of instance DB parameters to apply | <pre>list(object({<br>    apply_method = optional(string, "immediate")<br>    name         = string<br>    value        = string<br>  }))</pre> | `null` | no |
| deletion\_protection | A boolean indicating if the DB instance should have deletion protection enable | `bool` | `true` | no |
| enable\_http\_endpoint | Enable Aurora Serverless HTTP endpoint (Data API) | `bool` | `false` | no |
| enabled\_cloudwatch\_logs\_exports | List of log types to export to cloudwatch | `list(string)` | `null` | no |
| engine | The engine type of the Aurora cluster | `string` | `"aurora-mysql"` | no |
| engine\_mode | The engine mode of the Aurora cluster | `string` | `"serverless"` | no |
| engine\_version | The engine version of the Aurora cluster | `string` | `"5.7.mysql_aurora.2.08.3"` | no |
| final\_snapshot\_identifier | Identifier of the final snapshot to create before deleting the cluster | `string` | `null` | no |
| iam\_database\_authentication\_enabled | Specify if mapping AWS IAM accounts to database accounts is enabled. | `bool` | `null` | no |
| iam\_roles | A list of IAM Role ARNs to associate with the cluster | `list(string)` | `null` | no |
| instance\_class | The class of RDS instances to attach. Only for serverless engine\_mode | `string` | `"db.r5.large"` | no |
| instance\_count | The number of RDS instances to attach. Only for serverless engine\_mode | `number` | `1` | no |
| kms\_key\_id | The KMS key ID used for the storage encryption | `string` | `null` | no |
| max\_capacity | The maximum capacity of the serverless cluster | `string` | `8` | no |
| min\_capacity | The minimum capacity of the serverless cluster | `string` | `1` | no |
| monitoring\_interval | The interval (seconds) for collecting enhanced monitoring metrics | `string` | `null` | no |
| performance\_insights | Specifies whether Performance Insights is enabled or not | `bool` | `false` | no |
| performance\_insights\_retention\_period | Amount of time in days to retain Performance Insights data. Valida values are 7, 731 (2 years) or a multiple of 31. When specifying performance\_insights\_retention\_period, performance\_insights needs to be set to true | `number` | `7` | no |
| permissions\_boundary | The ARN of the policy that is used to set the permissions boundary for the role | `string` | `null` | no |
| preferred\_backup\_window | The daily time range during which automated backups are created, in UTC e.g. 04:00-09:00 | `string` | `null` | no |
| preferred\_maintenance\_window | The weekly time range during which system maintenance can occur, in UTC e.g. wed:04:00-wed:04:30 | `string` | `null` | no |
| publicly\_accessible | Control if instances in cluster are publicly accessible | `string` | `false` | no |
| security\_group\_ids | List of security group IDs allowed to connect to Aurora | `list(string)` | `[]` | no |
| snapshot\_identifier | Database snapshot identifier to create the database from | `string` | `null` | no |
| storage\_encrypted | Specifies whether the DB cluster is encrypted | `bool` | `true` | no |
| timeout\_action | The action to take when the timeout is reached | `string` | `"RollbackCapacityChange"` | no |

## Outputs

| Name | Description |
|------|-------------|
| arn | ARN of the Aurora cluster |
| cluster\_identifier | The RDS Cluster Identifier |
| cluster\_resource\_id | The RDS Cluster Resource ID |
| database | Name of the first database created when the cluster was created |
| endpoint | DNS address of the RDS instance |
| id | ID of the Aurora cluster |
| instance\_ids | ID's of RDS Aurora instances |
| port | Port on which the DB accepts connections |
| reader\_endpoint | A load-balanced read-only endpoint for the Aurora cluster |
| security\_group\_id | The securitiry group id that is attached to the Aurora cluster |
| username | Username for the master DB user |

<!--- END_TF_DOCS --->
