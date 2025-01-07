# Changelog

All notable changes to this project will automatically be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## v4.3.1 - 2025-01-07

### What's Changed

#### 🐛 Bug Fixes

* fix: Add Global Writer endpoint to the outputs (#62) @fatbasstard

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-aurora/compare/v4.3.0...v4.3.1

## v4.3.0 - 2025-01-06

### What's Changed

#### 🚀 Features

* feat: Add Global Database support (#61) @fatbasstard

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-aurora/compare/v4.2.2...v4.3.0

## v4.2.2 - 2024-12-16

### What's Changed

#### 🐛 Bug Fixes

* fix: Correct variable types (#60) @fatbasstard

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-aurora/compare/v4.2.1...v4.2.2

## v4.2.1 - 2024-12-13

### What's Changed

#### 🐛 Bug Fixes

* fix: Fix auto pauze configuration (#59) @fatbasstard

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-aurora/compare/v4.2.0...v4.2.1

## v4.2.0 - 2024-12-13

### What's Changed

#### 🚀 Features

* feature: Implement seconds_until_auto_pause to Serverless V2 and make configurable (#58) @fatbasstard

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-aurora/compare/v4.1.1...v4.2.0

## v4.1.1 - 2024-01-12

### What's Changed

#### 🐛 Bug Fixes

* fix: restore version bump (#56) @shoekstra
* bug: Fix resetting tags on every run (#55) @shoekstra

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-aurora/compare/v4.1.0...v4.1.1

## v4.1.0 - 2024-01-11

### What's Changed

#### 🚀 Features

* feat: Add PostgreSQL support (#54) @shoekstra

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-aurora/compare/v4.0.0...v4.1.0

## v4.0.0 - 2023-10-18

### What's Changed

#### 🚀 Features

- breaking: modify the way security group ingress rules are defined allowing for more flexibility (#53) @thulasirajkomminar

#### 🐛 Bug Fixes

- breaking: modify the way security group ingress rules are defined allowing for more flexibility (#53) @thulasirajkomminar

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-aurora/compare/v3.3.0...v4.0.0

## v3.3.0 - 2023-09-21

### What's Changed

#### 🚀 Features

- security: solve latest checkov findings, modify behaviour of performance_insights and cloudwatch_logs_export (#52) @marwinbaumannsbp
- feat: add the option to specify a custom parameter group name (#50) @marwinbaumannsbp

#### 🐛 Bug Fixes

- security: solve latest checkov findings, modify behaviour of performance_insights and cloudwatch_logs_export (#52) @marwinbaumannsbp
- bug: do not create cluster parameter group if no cluster parameters are specified (#51) @marwinbaumannsbp

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-aurora/compare/v3.2.1...v3.3.0

## v3.2.1 - 2023-09-18

### What's Changed

#### 🐛 Bug Fixes

- bug: solve dependency isues with modifying parameter groups (#49) @marwinbaumannsbp

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-aurora/compare/v3.2.0...v3.2.1

## v3.2.0 - 2023-07-18

### What's Changed

#### 🚀 Features

- feature: Adds custom_endpoints output (#44) @stefanwb

#### 🐛 Bug Fixes

- bug(entrypoint): Depend on cluster instances to exist (#43) @shoekstra

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-aurora/compare/v3.1.1...v3.2.0

## v3.1.1 - 2023-07-14

### What's Changed

#### 🐛 Bug Fixes

- bug:  `ca_cert_identifier` was only specified in the first cluster instance resource (#48) @marwinbaumannsbp

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-aurora/compare/v3.1.0...v3.1.1

## v3.1.0 - 2023-07-14

### What's Changed

#### 🚀 Features

- security: set cluster parameter `require_secure_transport` to ON by default and set apply methods (#47) @marwinbaumannsbp

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-aurora/compare/v3.0.0...v3.1.0

## v3.0.0 - 2023-07-14

### What's Changed

#### 🚀 Features

- feature: Add support for creating multi-az db cluster and setting a custom ca cert identifer (#45) @marwinbaumannsbp

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-aurora/compare/v2.0.1...v3.0.0

## v2.0.1 - 2023-06-16

### What's Changed

#### 🐛 Bug Fixes

- bug: support the creation of multiple RDS cluster endpoints in a single account (#42) @marwinbaumannsbp

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-aurora/compare/v2.0.0...v2.0.1

## v2.0.0 - 2023-04-18

### What's Changed

#### 🚀 Features

- breaking: add support for RDS managed master password (#41) @marwinbaumannsbp

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-aurora/compare/v1.0.0...v2.0.0

## v1.0.0 - 2023-03-30

### What's Changed

#### 🚀 Features

- breaking: add support for: specifying endpoints and instance settings | rename variables | improve default settings (#37) @shoekstra @marwinbaumannsbp

#### 📖 Documentation

- breaking: add support for: specifying endpoints and instance settings | rename variables | improve default settings (#37) @shoekstra @marwinbaumannsbp

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-aurora/compare/v0.6.0...v1.0.0

## v0.6.0 - 2023-03-21

### What's Changed

- docs: add release drafter config (#36) @marwinbaumannsbp

#### 🚀 Features

- enhancement: update workflows, add examples, solve tflint/checkov findings (#35) @marwinbaumannsbp

#### 📖 Documentation

- enhancement: update workflows, add examples, solve tflint/checkov findings (#35) @marwinbaumannsbp

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-aurora/compare/v0.5.3...v0.6.0

## v0.5.3 - 2023-01-06

### What's Changed

#### 🚀 Feature

- improvement: Calculate skip_final_snapshot (#34) @fatbasstard

**Full Changelog**: https://github.com/schubergphilis/terraform-aws-mcaf-aurora/compare/v0.5.2...v0.5.3
