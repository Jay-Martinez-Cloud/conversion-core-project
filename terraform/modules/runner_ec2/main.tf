data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_security_group" "runner" {
  name        = "${var.name}-runner-sg"
  description = "Private EC2 runner; no inbound. Access via SSM only."
  vpc_id      = var.vpc_id

  # No ingress rules (SSM only)

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { Name = "${var.name}-runner-sg" })
}

resource "aws_iam_role" "ssm_role" {
  name = "${var.name}-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.name}-instance-profile"
  role = aws_iam_role.ssm_role.name
}

locals {
  user_data = <<-EOF
    #!/bin/bash
    set -euxo pipefail

    # Log user-data output for debugging
    exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

    dnf update -y

    # Ensure SSM agent is installed and running (required for Session Manager)
    dnf install -y amazon-ssm-agent
    systemctl enable amazon-ssm-agent
    systemctl start amazon-ssm-agent
    systemctl restart amazon-ssm-agent
    systemctl status amazon-ssm-agent --no-pager || true

    # Expand root filesystem to match the EBS volume (no more manual growpart)
    dnf install -y cloud-utils-growpart
    growpart /dev/nvme0n1 1 || true
    xfs_growfs -d / || true

    # Docker for SQL Server container
    dnf install -y docker
    systemctl enable docker
    systemctl start docker

    # SQL Server 2022 container
    docker pull mcr.microsoft.com/mssql/server:2022-latest

    # Idempotent: remove old container if it exists
    docker rm -f sqlserver || true

    docker run -d --name sqlserver \
      -e "ACCEPT_EULA=Y" \
      -e "MSSQL_SA_PASSWORD=${var.sql_sa_password}" \
      -e "MSSQL_PID=Developer" \
      -p ${var.sql_port}:1433 \
      --restart unless-stopped \
      mcr.microsoft.com/mssql/server:2022-latest
  EOF
}

resource "aws_instance" "runner" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.runner.id]
  iam_instance_profile        = aws_iam_instance_profile.this.name
  user_data                   = local.user_data
  user_data_replace_on_change = true

  root_block_device {
    volume_size = 60
    volume_type = "gp3"
  }

  metadata_options {
    http_tokens = "required"
  }

  tags = merge(var.tags, {
    Name = "${var.name}-runner"
    Role = "conversion-runner"
  })
}
