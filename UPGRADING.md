# Upgrading Notes

This document captures breaking changes.

## Upgrading to v3.0.0

### Variables

The following variable defaults have been modified:

- `engine_mode` -> default: `provisioned` (previous: `serverless`)
- `instance_class` -> default: `null` (previous: `db.r5.large`)
- `ca_cert_identifier` -> default: `rds-ca-rsa2048-g1` (did not exist yet, previous: `rds-ca-2019`)

## Upgrading to v2.0.0

### Behaviour

Amazon RDS now supports [integration with AWS Secrets Manager to manage the master user password](https://aws.amazon.com/about-aws/whats-new/2022/12/amazon-rds-integration-aws-secrets-manager/). With this feature, RDS fully manages the master password and stores it in AWS Secrets Manager, this includes regular and automatic password rotations out of the box. All module versions as of `v2.0.0` have enabled this feature by default. The feature is controllable via `var.manage_master_user`.

You can update an existing cluster to use Secrets Manager by removing the `master_password` attribute.

### Variables

The following variables have been renamed:

- `password` -> `master_password`
- `username` -> `master_username`

The following variable defaults have been modified:

- `master_password` -> default: `null`

The following new variables have been introduced:

- `manage_master_user`
- `master_user_secret_kms_key_id`

The following outputs have been renamed:

- `username` -> `master_username`

The following new outputs have been introduced:

- `master_user_secret`

## Upgrading to v1.0.0

### Behaviour

All module versions before `v1.0.0` deployed the `aws_rds_cluster_instance` resource using a count. Because Terraform uses parallelism by default, using a single resource with a loop results in downtime when modifying certain variables. To mitigate this issue, a `first` `aws_rds_cluster_instance` resource is created and when creating two or more instances a `rest` `aws_rds_cluster_instance` resource with a count is created to ensure a single instance always stays available during modification.

Move the resources to their new locations in the state. Create a `moved.tf` file in your workspace and add the following resource instance (assuming your module is called `aurora` and you have deployed 2 or more cluster instances):

```hcl
moved {
  from = module.aurora.aws_rds_cluster_instance.cluster_instances[1]
  to   = module.aurora.aws_rds_cluster_instance.first[0]
}
```

This should ensure you keep 1 instance running, resulting in no-downtime during this upgrade. This wil still redeploy the other instances since we modifified the identifier from `count.index` to `count.index + 1`. To ensure that instance names start with `1` instead of `0`. This makes it more human friendly to overwrite instance settings using `instance_config`, because using e.g. `1` as an identifier really means the first cluster instance in this case and not the second cluster instance.

### Variables

The following variables have been renamed:

- `stack` -> `name`
- `cidr_blocks` -> `allowed_cidr_blocks`
- `security_group_ids` -> `allowed_security_group_ids`

The following variable defaults have been modified:

- `cluster_family` -> default: `aurora-mysql8.0`
- `engine_version` -> default: `8.0.mysql_aurora.3.02.2`
- `iam_database_authentication_enabled` -> default: `true`
- `instance_count` -> default: `2`
- `tags` -> default: `{}`
- `username` -> default: `root`

The following new variables have been introduced:

- `endpoints`

For certain Aurora tasks, different instances or groups of instances perform different roles. By specifying the variable `endpoints`, you can map each connection to the appropriate instance or group of instances based on your use case.

- `instance_config`

By default, all aurora cluster instances will be deployed using the same settings. Specific settings can be overwritten by using the variable `instance_config`. Read the variable description and the [full example](https://github.com/schubergphilis/terraform-aws-mcaf-aurora/blob/master/examples/full) for more information.
