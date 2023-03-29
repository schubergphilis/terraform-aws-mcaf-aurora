# Upgrading Notes

This document captures breaking changes.

## Upgrading to v1.0.0

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

- `cluster_endpoints`

For certain Aurora tasks, different instances or groups of instances perform different roles. By specifying the variable `cluster_endpoints`, you can map each connection to the appropriate instance or group of instances based on your use case.

- `instance_config`

By default, all aurora cluster instances will be deployed using the same settings. Specific settings can be overwritten by using the variable `instance_config`. Read the variable description and the [multi-az example](https://github.com/schubergphilis/terraform-aws-mcaf-aurora/blob/master/examples/multi-az) for more information.

### Behaviour

All module versions before `v1.0.0` deployed the `aws_rds_cluster_instance` resource using a count. Because Terraform uses parallelism by default, using a single resource with a loop results in downtime when modifying certain variables. To mitigate this issue, a `first` `aws_rds_cluster_instance` resource is created and when creating two or more instances a `rest` `aws_rds_cluster_instance` resource with a count is created to ensure a single instance always stays available during modification.

Move the resources to their new locations in the state. Create a `moved.tf` file in your workspace and add the following for each `aws_rds_cluster_instance` resource instance (assuming your module is called `aurora`):

```hcl
moved {
  from = module.aurora.aws_rds_cluster_instance.cluster_instances[0]
  to   = module.aurora.aws_rds_cluster_instance.first[0]
}

moved {
  from = module.aurora.aws_rds_cluster_instance.cluster_instances[1]
  to   = module.aurora.aws_rds_cluster_instance.rest[0]
}

moved {
  from = module.aurora.aws_rds_cluster_instance.cluster_instances[2]
  to   = module.aurora.aws_rds_cluster_instance.rest[1]
}
```

Note: This will still result in a redeploy of the first instance since we modifified the identifier from `count.index` to `count.index + 1`. To ensure that instance names start with `1` instead of `0`. This makes it easier to overwrite instance settings using `instance_config`, because using e.g. `1` as an identifier really means the first cluster instance in this case and not the second cluster instance.
