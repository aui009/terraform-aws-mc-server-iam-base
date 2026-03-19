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