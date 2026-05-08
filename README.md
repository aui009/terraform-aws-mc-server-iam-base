# terraform-aws-mc-server-iam-base

## Overview

This repository deploys the foundational AWS IAM infrastructure for the Minecraft server ecosystem. It creates IAM roles and policies that define permissions for EC2 instances, Lambda functions, Step Functions, and EventBridge, enabling secure cross-service communication and resource management.

This is the first IAM layer to deploy and is a prerequisite for all other Minecraft server repositories.

## IAM Roles

### mc_server_role
EC2 instance role for Minecraft server instances. Provides permissions for:
- S3 access (read/write server configuration and backup files)
- SSM Parameter Store access (read server schedules and configuration)
- CloudWatch Logs (write server logs and metrics)
- SQS access (send events to Miku queue)
- Lambda invocation (trigger backup/management functions)
- CloudWatch Agent and SSM agent managed policies (AWS managed)

### step_fn_role_ssm_ec2_role
Step Function execution role. Provides permissions for:
- Running SSM commands on EC2 instances
- Executing Step Function operations

### eventbridge_step_fn_role
EventBridge role for triggering Step Function state machines. Provides permissions for:
- Starting Step Function executions

### evenbridge_ssm_role
EventBridge role for SSM integration. Provides permissions for:
- Putting events to EventBridge from SSM

## IAM Policies

### EC2 and Instance Policies
- **s3_mc_server_policy** — S3 read/write access for server configuration and backups
- **ssm_ec2_mc_server_policy** — SSM Parameter Store read-only access
- **iam_cloudwatch_roles_ec2_mc_server_policy** — CloudWatch Logs write access
- **ec2_lambda_invoke_policy** — EC2 to Lambda invocation
- **ec2_snapshot_retention_policy** — EBS snapshot retention management

### Lambda Policies
- **lambda_policy_stop_instances** — Stop EC2 instances and describe them
- **lambda_policy_start_instances** — Start EC2 instances and describe them
- **lambda_policy_desc_instances_only** — Describe EC2 instances only
- **lambda_policy_ssm_policy** — SSM Parameter Store access for Lambda
- **ssm_get_parameter_only_policy** — Get-only access to SSM parameters
- **lambda_ec2startinstance_disc_policy** — Start EC2 and describe instances
- **miku_sqs_policy** — Send SQS messages to Miku queue

### Orchestration Policies
- **ssm_step_fn_policy** — SSM run Step Function execution
- **lambda_invoke_step_fn_policy** — Lambda to invoke Step Functions
- **ssm_eventbridge_policy** — SSM to put events to EventBridge

## Repository structure

- `main.tf` — core IAM roles, policies, and attachments
- `locals.tf` — IAM policy definitions in JSON format, remote state data source
- `output.tf` — exported role ARNs and policy ARNs for downstream repositories
- `backend.tf` — S3 backend configuration
- `config/backend_dev.conf` — backend configuration for dev workspace
- `config/backend_prod.conf` — backend configuration for prod workspace
- `policies/` — reference policy JSON files (used during development)

## Deployment

1. Choose or create the workspace for the target environment:
   ```bash
   terraform workspace select dev || terraform workspace new dev
   ```

2. Initialize Terraform with the matching backend config:
   ```bash
   terraform init -backend-config=config/backend_dev.conf
   ```

3. Review the planned changes:
   ```bash
   terraform plan
   ```

4. Apply the configuration:
   ```bash
   terraform apply
   ```

For production, use `config/backend_prod.conf` and the `prod` workspace.

## Outputs

### IAM Roles
- `mc_server_role_arn` — ARN of the EC2 instance role for Minecraft server
- `step_fn_role_ssm_ec2_role_arn` — ARN of the Step Function execution role
- `eventbridge_step_fn_role_arn` — ARN of the EventBridge to Step Function role
- `evenbridge_ssm_role_arn` — ARN of the EventBridge to SSM role

### IAM Policies
- `lambda_policy_stop_instances_arn` — Stop instances policy ARN
- `lambda_policy_start_instances_arn` — Start instances policy ARN
- `lambda_policy_desc_instances_only_arn` — Describe instances policy ARN
- `lambda_policy_ssm_policy_arn` — Lambda SSM access policy ARN
- `ssm_get_parameter_only_policy_arn` — SSM get-only policy ARN
- `lambda_ec2startinstance_disc_policy_arn` — Start and describe instances policy ARN
- `miku_sqs_policy_arn` — Miku SQS send policy ARN
- `s3_mc_server_policy_arn` — S3 access policy ARN
- `ssm_ec2_mc_server_policy_arn` — SSM access policy ARN
- `iam_cloudwatch_roles_ec2_mc_server_policy_arn` — CloudWatch access policy ARN
- `ec2_snapshot_retention_policy_arn` — Snapshot retention policy ARN

## Dependencies

This repository reads remote state from `terraform-aws-mc-server-base` to access:
- SQS queue ARN (for miku_sqs_policy)
- Lambda layer ARNs (for policy creation reference)

It has no external dependencies beyond the remote state; `terraform-aws-mc-server-base` must be deployed first.

## Prerequisites for dependent repositories

Other Minecraft server repositories depend on this IAM base layer:
- `minecraft_server_aws` — uses `mc_server_role_arn` for EC2 instances
- `terraform-aws-mc-event-handler` — uses Lambda and EventBridge role ARNs
- `terraform-aws-mc-server-observability` — uses monitoring roles

## Notes

- The IAM role `mc-server-status-role` is created and used by EC2 instances in `minecraft_server_aws`
- All policies follow the principle of least privilege with specific resource restrictions
- Remote state is read from S3 backend matching the workspace name
- AWS credentials must be configured before running Terraform
- The account ID is automatically detected from the current AWS account
- AWS managed policies are attached for CloudWatch Agent and SSM core functionality