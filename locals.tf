data "aws_caller_identity" "current" {}

data "terraform_remote_state" "based_layers" {
  backend = "s3"
  config = {
    bucket = "terraform-state-file-ap-southeast-1-${terraform.workspace}"
    key    = "env:/${terraform.workspace}/minecraft/base_layers/terraform.tfstate"
    region = "ap-southeast-1"
  }
}

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
            , "ssm:ListCommands"
            , "ssm:ListCommandInvocations"
            , "ssm:GetCommandInvocation"
          ],
          "Resource" : [
            "arn:aws:ec2:*:${local.account_id}:instance/*",
            "arn:aws:ssm:ap-southeast-1::document/*",
            "arn:aws:ssm:ap-southeast-1:${local.account_id}:*"
          ]
        }
      ]
    }),

    miku_sqs_policy_only = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "VisualEditor0",
          "Effect" : "Allow",
          "Action" : "sqs:SendMessage",
          "Resource" : data.terraform_remote_state.based_layers.outputs.miku_queue_sqs_arn
        }
      ]
    }),

    ec2_lambda_invoke_policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "VisualEditor0",
          "Effect" : "Allow",
          "Action" : "lambda:InvokeFunction",
          "Resource" : "arn:aws:lambda:*:${local.account_id}:function:*"
        }
      ]
    }),

    ssm_step_fn_policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "VisualEditor0",
          "Effect" : "Allow",
          "Action" : [
            "ec2:DescribeInstances",
            "ssm:GetCommandInvocation"
          ],
          "Resource" : "*"
        },
        {
          "Sid" : "VisualEditor1",
          "Effect" : "Allow",
          "Action" : "ssm:SendCommand",
          "Resource" : [
            "arn:aws:ec2:*:${local.account_id}:instance/*",
            "arn:aws:ssm:*:${local.account_id}:document/*"
          ]
        }
      ]
    }),

    lambda_invoke_step_fn_policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "lambda:InvokeFunction"
          ],
          "Resource" : [
            "arn:aws:lambda:ap-southeast-1:${local.account_id}:function:mc_sendSQStoMiku_handler_server_sched_up:*",
            "arn:aws:lambda:ap-southeast-1:${local.account_id}:function:mc_sendSQStoMiku_handler_server_down:*",
            "arn:aws:lambda:ap-southeast-1:${local.account_id}:function:mc_sendSQStoMiku_handler_server_down"
          ]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "lambda:InvokeFunction"
          ],
          "Resource" : [
            "arn:aws:lambda:ap-southeast-1:${local.account_id}:function:mc_sendSQStoMiku_handler_server_sched_up"
          ]
        }
      ]
    }),

    step_fn_assume_role_policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "states.amazonaws.com"
          },
          "Action" : "sts:AssumeRole"
        }
      ]
      }
    ),

    ssm_get_parameter_only_policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "VisualEditor0",
          "Effect" : "Allow",
          "Action" : "ssm:GetParameter",
          "Resource" : "arn:aws:ssm:*:${local.account_id}:parameter/*"
        }
      ]
      }
    ),

    lambda_ec2startinstance_disc_policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Sid" : "VisualEditor0",
          "Effect" : "Allow",
          "Action" : [
            "s3:GetObject",
            "secretsmanager:GetSecretValue",
            "ec2:StartInstances",
            "ec2:DescribeInstances"
          ],
          "Resource" : [
            "arn:aws:secretsmanager:*:${local.account_id}:secret:*",
            "arn:aws:ec2:*:${local.account_id}:instance/*",
            "arn:aws:s3:::*/*"
          ]
        }
      ]
      }
    )

    ###########################################################
    # End of IAM policies in JSON format for MC Server
    ###########################################################
  }
  ###########################################################
  # Local Variables Base IAM
  ###########################################################
  env_var = terraform.workspace
}