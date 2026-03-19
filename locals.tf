data "aws_caller_identity" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id

  iam_policies_json = {
    ###########################################################
    # IAM policies in JSON format for MC Server
    ###########################################################
    ec2_assume_role_policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "ec2.amazonaws.com"
          },
          "Action" : "sts:AssumeRole"
        }
      ]
    }),

    iam_cw_roles_ec2_mc_server_policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "IAMEC2RoleMC",
          "Effect" : "Allow",
          "Action" : [
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents",
            "logs:DescribeLogStreams"
          ],
          "Resource" : [
            "*"
          ]
        }
      ]
    }),

    lambda_policy_stop_instances = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "VisualEditor0",
          "Effect" : "Allow",
          "Action" : [
            "ec2:StopInstances",
            "ec2:DescribeInstances"
          ],
          "Resource" : "*"
        }
      ]
    }),
    s3_mc_server_policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "s3:Get*",
            "s3:List*",
            "s3:Describe*",
            "s3-object-lambda:Get*",
            "s3-object-lambda:List*",
            "s3:PutObject"
          ],
          "Resource" : "arn:aws:s3:::*/*"
        }
      ]
    }),

    ssm_ec2_mc_server_policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "VisualEditor0",
          "Effect" : "Allow",
          "Action" : "ssm:GetParameter",
          "Resource" : [
            "arn:aws:ssm:*:${local.account_id}:parameter/*",
            "arn:aws:ssm:*:${local.account_id}:*"
          ]
        }
      ]
    }),

    lambda_policy_start_instances = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "VisualEditor0",
          "Effect" : "Allow",
          "Action" : [
            "ec2:StartInstances",
            "ec2:DescribeInstances"
          ],
          "Resource" : "*"
        }
      ]
    }),

    lambda_policy_desc_instances_only = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "VisualEditor0",
          "Effect" : "Allow",
          "Action" : [
            "ec2:DescribeInstances"
          ],
          "Resource" : "*"
        }
      ]
    }),

    lambda_policy_ssm_policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "VisualEditor0",
          "Effect" : "Allow",
          "Action" : [
            "ssm:SendCommand"
           ,"ssm:ListCommands"
           ,"ssm:ListCommandInvocations"
           ,"ssm:GetCommandInvocation"
          ],
          "Resource" : "arn:aws:ec2:*:523761210076:instance/*"
        }
      ]
    })
    ###########################################################
    # End of IAM policies in JSON format for MC Server
    ###########################################################
  }
  ###########################################################
  # Local Variables Base IAM
  ###########################################################
}