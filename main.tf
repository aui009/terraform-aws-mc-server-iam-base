###########################################################
#                 IAM Roles                               #
###########################################################

resource "aws_iam_role" "mc_server_role" {
  name               = "mc-server-status-role"
  assume_role_policy = file("${path.module}/policies/ec2_assume_role_policy.json")
}

###########################################################
#                 IAM Policies                            #
###########################################################

resource "aws_iam_policy" "s3_mc_server_policy" {
  name        = "s3-mc-server-policy"
  description = "Policy for MC Server to access S3 bucket"
  policy      = local.iam_policies_json["s3_mc_server_policy"]
}

resource "aws_iam_policy" "ssm_ec2_mc_server_policy" {
  name        = "ssm-ec2-mc-server-policy"
  description = "Policy for MC Server to access SSM Parameter Store"
  policy      = local.iam_policies_json["ssm_ec2_mc_server_policy"]
}

resource "aws_iam_policy" "iam_cloudwatch_roles_ec2_mc_server_policy" {
  name        = "iam-cloudwatch-roles-ec2-mc-server-policy"
  description = "Policy for MC Server to access CloudWatch Logs and IAM Roles"
  policy      = local.iam_policies_json["iam_cw_roles_ec2_mc_server_policy"]
}

resource "aws_iam_policy" "lambda_policy_stop_instances" {
  name        = "lambda-policy-stop-instances-policy"
  description = "Policy for Lambda function to stop EC2 instances only"
  policy      = local.iam_policies_json["lambda_policy_stop_instances"]
}

resource "aws_iam_policy" "lambda_policy_start_instances" {
  name        = "lambda-policy-start-instances-policy"
  description = "Policy for Lambda function to start EC2 instances only"
  policy      = local.iam_policies_json["lambda_policy_start_instances"]
}

###########################################################
#                 IAM Policies Roles Attachement          #
###########################################################

resource "aws_iam_role_policy_attachment" "s3_mc_server_policy_attachment" {
  role       = aws_iam_role.mc_server_role.name
  policy_arn = aws_iam_policy.s3_mc_server_policy.arn
}

resource "aws_iam_role_policy_attachment" "ssm_ec2_mc_server_policy_attachment" {
  role       = aws_iam_role.mc_server_role.name
  policy_arn = aws_iam_policy.ssm_ec2_mc_server_policy.arn
}

resource "aws_iam_role_policy_attachment" "iam_cloudwatch_roles_ec2_mc_server_policy_attachment" {
  role       = aws_iam_role.mc_server_role.name
  policy_arn = aws_iam_policy.iam_cloudwatch_roles_ec2_mc_server_policy.arn
}

resource "aws_iam_role_policy_attachment" "other_policies_attachment" {
  for_each = toset([
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  ])
  role       = aws_iam_role.mc_server_role.name
  policy_arn = each.value
}

###########################################################
#                 IAM Roles Imports                       #
###########################################################

/*import {
    to = aws_iam_role.mc_server_role
    id = "mc-server-status-role"
}*/