##############################################################
# Outputs for IAM Roles
##############################################################
output "mc_server_role_arn" {
  description = "ARN of the IAM role for Minecraft server EC2 instance"
  value       = aws_iam_role.mc_server_role.arn
}

output "step_fn_role_ssm_ec2_role_arn" {
  description = "ARN of the IAM role for Step Function to manage SSM and EC2"
  value       = aws_iam_role.step_fn_role_ssm_ec2_role.arn
}

output "eventbridge_step_fn_role_arn" {
  description = "ARN of the IAM role for EventBridge to start Step Function execution"
  value       = aws_iam_role.eventbridge_step_fn_role.arn
}
##############################################################
# Outputs for IAM policies
##############################################################

output "lambda_policy_stop_instances_arn" {
  description = "ARN of the Lambda policy that allows stopping EC2 instances"
  value       = aws_iam_policy.lambda_policy_stop_instances.arn
}

output "s3_mc_server_policy_arn" {
  description = "ARN of the S3 policy for MC Server"
  value       = aws_iam_policy.s3_mc_server_policy.arn
}

output "ssm_ec2_mc_server_policy_arn" {
  description = "ARN of the SSM policy for MC Server"
  value       = aws_iam_policy.ssm_ec2_mc_server_policy.arn
}

output "iam_cloudwatch_roles_ec2_mc_server_policy_arn" {
  description = "ARN of the IAM/CloudWatch policy for MC Server"
  value       = aws_iam_policy.iam_cloudwatch_roles_ec2_mc_server_policy.arn
}

output "lambda_policy_start_instances_arn" {
  description = "ARN of the Lambda policy that allows starting EC2 instances"
  value       = aws_iam_policy.lambda_policy_start_instances.arn
}

output "lambda_policy_desc_instances_only_arn" {
  description = "ARN of the Lambda policy that allows describing EC2 instances only"
  value       = aws_iam_policy.lambda_policy_desc_instances_only.arn
}

output "lambda_policy_ssm_policy_arn" {
  description = "ARN of the Lambda policy that allows access to SSM Parameter Store"
  value       = aws_iam_policy.lambda_policy_ssm_policy.arn
}

output "miku_sqs_policy_arn" {
  description = "ARN of the SQS policy for sending messages to Miku"
  value       = aws_iam_policy.miku_sqs_policy.arn
}

output "ssm_get_parameter_only_policy_arn" {
  description = "ARN of the SSM policy that allows getting parameters from SSM Parameter Store only"
  value       = aws_iam_policy.ssm_get_parameter_only_policy.arn
}