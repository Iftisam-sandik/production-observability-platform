data "aws_ssm_parameter" "ubuntu_ami" {
  name = "/aws/service/canonical/ubuntu/server/26.04/stable/current/amd64/hvm/ebs-gp3/ami-id"
}

resource "aws_instance" "app_1" {
  ami                         = data.aws_ssm_parameter.ubuntu_ami.value
  instance_type               = "t3.small"
  subnet_id                   = aws_subnet.public_a.id
  vpc_security_group_ids      = [aws_security_group.app.id]
  key_name                    = aws_key_pair.project.key_name
  associate_public_ip_address = true

  credit_specification {
    cpu_credits = "standard"
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 10
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name       = "app-server-1"
    Role       = "application"
    Monitoring = "enabled"
  }
}

resource "aws_instance" "app_2" {
  ami                         = data.aws_ssm_parameter.ubuntu_ami.value
  instance_type               = "t3.small"
  subnet_id                   = aws_subnet.public_b.id
  vpc_security_group_ids      = [aws_security_group.app.id]
  key_name                    = aws_key_pair.project.key_name
  associate_public_ip_address = true

  credit_specification {
    cpu_credits = "standard"
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 10
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name       = "app-server-2"
    Role       = "application"
    Monitoring = "enabled"
  }
}

resource "aws_instance" "db" {
  ami                         = data.aws_ssm_parameter.ubuntu_ami.value
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public_a.id
  vpc_security_group_ids      = [aws_security_group.db.id]
  key_name                    = aws_key_pair.project.key_name
  associate_public_ip_address = true

  credit_specification {
    cpu_credits = "standard"
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 12
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name       = "db-server"
    Role       = "database"
    Monitoring = "enabled"
  }
}

resource "aws_instance" "monitoring" {
  ami                         = data.aws_ssm_parameter.ubuntu_ami.value
  instance_type               = "t3.medium"
  subnet_id                   = aws_subnet.public_b.id
  vpc_security_group_ids      = [aws_security_group.monitoring.id]
  key_name                    = aws_key_pair.project.key_name
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.monitoring.name

  credit_specification {
    cpu_credits = "standard"
  }

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 15
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name       = "monitoring-server"
    Role       = "monitoring"
    Monitoring = "enabled"
  }
}
