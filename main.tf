###########################################################
#                 IAM Roles                               #
###########################################################

resource "aws_iam_role" "mc_server_role" {
  name               = "mc-server-status-role"
  assume_role_policy = file("${path.module}/policies/ec2_assume_role_policy.json")
}

resource "aws_iam_role" "step_fn_role_ssm_ec2_role" {
  name               = "step-fn-ssm-ec2-role"
  assume_role_policy = local.iam_policies_json["step_fn_assume_role_policy"]
}

resource "aws_iam_role" "eventbridge_step_fn_role" {
  name = "eventbridge-step-fn-role"
  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect : "Allow",
        Principal : {
          Service : "events.amazonaws.com"
        },
        Action : "sts:AssumeRole"
      }
    ]
  })
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

resource "aws_iam_policy" "ssm_step_fn_policy" {
  name        = "ssm-step-fn-policy"
  description = "Policy for SSM to run Step Functions execution"
  policy      = local.iam_policies_json["ssm_step_fn_policy"]
}

resource "aws_iam_policy" "lambda_invoke_step_fn_policy" {
  name        = "lambda-invoke-step-fn-policy"
  description = "Policy for step function to invoke lambda functions"
  policy      = local.iam_policies_json["lambda_invoke_step_fn_policy"]
}

resource "aws_iam_role_policy" "eventbridge_policy" {
  name = "eventbridge_sfn_policy"
  role = aws_iam_role.eventbridge_step_fn_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "states:StartExecution"
      Resource = "arn:aws:states:*:${local.account_id}:stateMachine:*"
    }]
  })
}

resource "aws_iam_policy" "ssm_get_parameter_only_policy" {
  name        = "ssm-get-parameter-only-policy"
  description = "Policy for Lambda function to get parameters from SSM Parameter Store only"
  policy      = local.iam_policies_json["ssm_get_parameter_only_policy"]
}

resource "aws_iam_policy" "lambda_ec2startinstance_disc_policy" {
  name        = "lambda-ec2startinstance-disc-policy"
  description = "Policy for Lambda function to start EC2 instances and describe them"
  policy      = local.iam_policies_json["lambda_ec2startinstance_disc_policy"]
}
###########################################################################
#                 IAM Policies Roles Attachement - MC Server Role          
###########################################################################

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
    , "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ])
  role       = aws_iam_role.mc_server_role.name
  policy_arn = each.value
}

###########################################################################
#                 IAM Policies Roles Attachement - Step Function Role          
###########################################################################
resource "aws_iam_role_policy_attachment" "ssm_step_fn_policy_attachment" {
  role       = aws_iam_role.step_fn_role_ssm_ec2_role.name
  policy_arn = aws_iam_policy.ssm_step_fn_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_invoke_step_fn_policy_attachment" {
  role       = aws_iam_role.step_fn_role_ssm_ec2_role.name
  policy_arn = aws_iam_policy.lambda_invoke_step_fn_policy.arn
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