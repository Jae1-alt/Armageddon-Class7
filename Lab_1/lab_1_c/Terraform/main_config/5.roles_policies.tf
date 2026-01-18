# Data lookup for current user
data "aws_caller_identity" "current" {}

resource "aws_iam_role" "ec2_lab_role" {
  name = "${var.environment}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

# Policy to connect via SSM Session Manager
resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ec2_lab_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cw_agent_policy" {
  role = aws_iam_role.ec2_lab_role.name

  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_policy" "db_access_policy" {
  name        = "${var.environment}-app-access-policy"
  description = "Scoped access to specific parameters, secrets, and logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "ReadSpecificSecret"
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = "arn:aws:secretsmanager:${var.region}:${data.aws_caller_identity.current.account_id}:secret:${var.secret_name}*"
      },
      {
        Sid      = "ReadSpecificParams"
        Effect   = "Allow"
        Action   = ["ssm:GetParameter", "ssm:GetParameters"]
        Resource = "arn:aws:ssm:${var.region}:${data.aws_caller_identity.current.account_id}:parameter${var.db_config_path}*"
      },
      {
        Sid    = "WriteLogsAndMetrics"
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "cloudwatch:PutMetricData"
        ]
        Resource = "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/ec2/lab-rds-app:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "custom_db_attach" {
  role       = aws_iam_role.ec2_lab_role.name
  policy_arn = aws_iam_policy.db_access_policy.arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.environment}-instance-profile"
  role = aws_iam_role.ec2_lab_role.name
}