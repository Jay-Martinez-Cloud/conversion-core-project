#######################################
# EC2 - Linux SQL Server Host (Docker)
#######################################

# Latest Amazon Linux 2023 AMI
data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# Security Group for SQL host (internal only)
resource "aws_security_group" "sql_host" {
  name        = "${local.name_prefix}-sql-host-sg"
  description = "SQL host (Docker) in private subnet"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SQL Server from inside VPC only"
    from_port   = 1433
    to_port     = 1433
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-sql-host-sg"
  })
}

resource "aws_instance" "sql_host" {
  ami                         = data.aws_ami.al2023.id
  instance_type               = "t3.medium"
  subnet_id                   = aws_subnet.private_a.id
  vpc_security_group_ids      = [aws_security_group.sql_host.id]
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name
  associate_public_ip_address = false

  root_block_device {
    volume_size = 40
    volume_type = "gp3"
  }

  user_data = <<-EOFUSERDATA
              #!/bin/bash
              set -e

              dnf -y update
              dnf -y install docker
              systemctl enable docker
              systemctl start docker

              docker pull mcr.microsoft.com/mssql/server:2019-latest

              docker run -d --name sql2019 \
                -e "ACCEPT_EULA=Y" \
                -e "MSSQL_SA_PASSWORD=${var.mssql_sa_password}" \
                -p 1433:1433 \
                --restart unless-stopped \
                mcr.microsoft.com/mssql/server:2019-latest
              EOFUSERDATA

  tags = merge(local.tags, {
    Name = "${local.name_prefix}-sql-host-linux"
  })
}
