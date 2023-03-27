# Upgrading Notes

This document captures breaking changes.

## Upgrading to v1.0.0

### Variables

The following variables have been renamed:

- `stack` -> `name`
- `cidr_blocks` -> `security_group_rules.ingress_allowed_cidr_blocks`
- `security_group_ids` -> `security_group_rules.ingress_allowed_security_group_ids`

The following variable defaults have been modified:

- `cluster_family` -> default: `aurora-mysql8.0`
- `engine_version` -> default: `8.0.mysql_aurora.3.02.2`
- `iam_database_authentication_enabled` -> default: `true`
- `tags` -> default: `{}`
- `username` -> default: `root`

The following new variables have been introduced:

- `cluster_endpoints`
- `instance_config`

By default, all aurora cluster instances will be deployed using the same settings. Specific settings can be overwritten by using the variable `instance_config`. Read the variable description and the [multi-az example](https://github.com/schubergphilis/terraform-aws-mcaf-aurora/blob/master/examples/multi-az) for more information.

### Behaviour

All module versions before `v1.0.0` deployed the `aws_rds_cluster_instance` resource using a count. Because Terraform uses parallelism by default, using a single resource with a loop results in downtime when modifying certain variables. To mitigate this issue, a `first` `aws_rds_cluster_instance` resource is created and when creating two or more instances a `rest` `aws_rds_cluster_instance` resource with a count is created to ensure a single instance always stays available during modification.

To move the resources to their new locations in the state, create a moved.tf in your workspace and add the following for each `aws_rds_cluster_instance` resource instance (assuming your module is called `aurora`):

```hcl
moved {
  todo
}
```
