resource "aws_iam_role" "monitoring" {
  name = "observability-monitoring-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "observability-monitoring-role"
  }
}

resource "aws_iam_role_policy" "monitoring_ec2_discovery" {
  name = "prometheus-ec2-discovery"
  role = aws_iam_role.monitoring.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeTags",
          "ec2:DescribeAvailabilityZones"
        ]

        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "monitoring" {
  name = "observability-monitoring-profile"
  role = aws_iam_role.monitoring.name
}
