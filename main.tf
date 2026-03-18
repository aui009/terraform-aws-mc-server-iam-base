###########################################################
#                 IAM Roles                               #
###########################################################

resource aws_iam_role mc_server_role {
  name = "mc-server-status-role"
  assume_role_policy = jsondecode(filepath("${path.module}/policies/ec2_assume_role_policy.json"))
}

###########################################################
#                 IAM Policies                            #
###########################################################

resource aws_iam_policy s3_mc_server_policy {
  name = "s3-mc-server-policy"
  description = "Policy for MC Server to access S3 bucket"
  policy = file("${path.module}/policies/s3_mc_server_policy.json")
}

resource aws_iam_policy ssm_ec2_mc_server_policy {
  name = "ssm-ec2-mc-server-policy"
  description = "Policy for MC Server to access SSM Parameter Store"
  policy = file("${path.module}/policies/ssm_ec2_mc_server_policy.json")
}

resource aws_iam_policy iam_cloudwatch_roles_ec2_mc_server_policy {
  name = "iam-cloudwatch-roles-ec2-mc-server-policy"
  description = "Policy for MC Server to access CloudWatch Logs and IAM Roles"
  policy = file("${path.module}/policies/iam_cloudwatch_roles_ec2_mc_server_policy.json")
}

###########################################################
#                 IAM Policies Roles Attachement          #
###########################################################

resource aws_iam_role_policy_attachment s3_mc_server_policy_attachment {
    for_each = [
        aws_iam_policy.s3_mc_server_policy,
        aws_iam_policy.ssm_ec2_mc_server_policy,
        aws_iam_policy.iam_cloudwatch_roles_ec2_mc_server_policy,
        "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
    ]
    role = aws_iam_role.mc_server_role.name
    policy_arn = each.value.arn
}

###########################################################
#                 IAM Roles Imports                       #
###########################################################

import {
    to = aws_iam_role.mc_server_role
    id = "mc-server-status-role"
}