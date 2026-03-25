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

resource "aws_iam_policy" "lambda_policy_desc_instances_only" {
  name        = "lambda-policy-desc-instances-policy"
  description = "Policy for Lambda function to describe EC2 instances only"
  policy      = local.iam_policies_json["lambda_policy_desc_instances_only"]
}

resource "aws_iam_policy" "lambda_policy_ssm_policy" {
  name        = "lambda-policy-ssm-policy"
  description = "Policy for Lambda function to access SSM Parameter Store"
  policy      = local.iam_policies_json["lambda_policy_ssm_policy"]
}

resource "aws_iam_policy" "miku_sqs_policy" {
  name        = "miku-sqs-${local.env_var}-policy"
  description = "policy for sqs entity miku"
  policy      = local.iam_policies_json["miku_sqs_policy_only"]
}

resource "aws_iam_policy" "ec2_lambda_invoke_policy" {
  name        = "ec2-lambda-invoke-policy"
  description = "policy for ec2 to invoke lambda function"
  policy      = local.iam_policies_json["ec2_lambda_invoke_policy"]
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

resource "aws_iam_role_policy_attachment" "miku_sqs_policy_attachment" {
  role       = aws_iam_role.mc_server_role.name
  policy_arn = aws_iam_policy.miku_sqs_policy.arn
}

resource "aws_iam_role_policy_attachment" "ec2_lambda_invoke_policy_attachment" {
  role       = aws_iam_role.mc_server_role.name
  policy_arn = aws_iam_policy.ec2_lambda_invoke_policy.arn
}

resource "aws_iam_role_policy_attachment" "other_policies_attachment" {
  for_each = toset([
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
   ,"arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
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
/*import {
  to = aws_iam_policy.miku_sqs_policy
  id = "arn:aws:iam::523761210076:policy/miku-sqs-dev-policy"
}*/