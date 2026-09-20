resource "aws_security_group" "alb" {
  name        = "observability-alb-sg"
  description = "Security group for the application load balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "observability-alb-sg"
  }
}

resource "aws_security_group" "monitoring" {
  name        = "observability-monitoring-sg"
  description = "Security group for the monitoring server"
  vpc_id      = aws_vpc.main.id

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "observability-monitoring-sg"
  }
}

resource "aws_security_group" "app" {
  name        = "observability-app-sg"
  description = "Security group for application servers"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }

  ingress {
    description     = "Application traffic from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description     = "Application metrics from monitoring server"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.monitoring.id]
  }

  ingress {
    description     = "Node Exporter from monitoring server"
    from_port       = 9100
    to_port         = 9100
    protocol        = "tcp"
    security_groups = [aws_security_group.monitoring.id]
  }

  ingress {
    description     = "cAdvisor from monitoring server"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.monitoring.id]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "observability-app-sg"
  }
}

resource "aws_security_group" "db" {
  name        = "observability-db-sg"
  description = "Security group for the database server"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_cidr]
  }

  ingress {
    description     = "MySQL from application servers"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  ingress {
    description     = "Node Exporter from monitoring server"
    from_port       = 9100
    to_port         = 9100
    protocol        = "tcp"
    security_groups = [aws_security_group.monitoring.id]
  }

  ingress {
    description     = "MySQL exporter from monitoring server"
    from_port       = 9104
    to_port         = 9104
    protocol        = "tcp"
    security_groups = [aws_security_group.monitoring.id]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "observability-db-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "monitoring_ssh" {
  security_group_id = aws_security_group.monitoring.id
  description       = "SSH from my IP"

  cidr_ipv4   = var.ssh_cidr
  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "grafana_access" {
  security_group_id = aws_security_group.monitoring.id
  description       = "Grafana from my IP"

  cidr_ipv4   = var.ssh_cidr
  from_port   = 3000
  to_port     = 3000
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "loki_from_app" {
  security_group_id            = aws_security_group.monitoring.id
  referenced_security_group_id = aws_security_group.app.id
  description                  = "Loki ingestion from application servers"

  from_port   = 3100
  to_port     = 3100
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "loki_from_db" {
  security_group_id            = aws_security_group.monitoring.id
  referenced_security_group_id = aws_security_group.db.id
  description                  = "Loki ingestion from database server"

  from_port   = 3100
  to_port     = 3100
  ip_protocol = "tcp"
}
