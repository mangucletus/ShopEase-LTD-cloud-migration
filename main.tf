provider "aws" {
  region = "us-east-1"
}

#----------------------------
# 1. VPC and Networking Setup
#----------------------------
resource "aws_vpc" "shopease_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "shopease-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.shopease_vpc.id
  tags = {
    Name = "shopease-igw"
  }
}

# Public Subnets
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.shopease_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "shopease-public-subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.shopease_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "shopease-public-subnet-2"
  }
}

# Private Subnets
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.shopease_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "shopease-private-subnet-1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.shopease_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "shopease-private-subnet-2"
  }
}

# Route Table for public subnet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.shopease_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "shopease-public-rt"
  }
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

# NAT Gateway for private instances
resource "aws_eip" "nat_eip" {
  vpc = true
  tags = {
    Name = "shopease-nat-eip"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_1.id
  tags = {
    Name = "shopease-nat-gateway"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.shopease_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
  tags = {
    Name = "shopease-private-rt"
  }
}

resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_rt.id
}

#------------------------
# 2. Key Pair for SSH
#------------------------
resource "aws_key_pair" "bastion_key" {
  key_name   = "bastion-key"
  public_key = file("~/.ssh/id_rsa.pub") # Update with correct path
}

#------------------------
# 3. Security Groups
#------------------------

# Bastion Host SG (SSH from anywhere for now)
resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "Allow SSH"
  vpc_id      = aws_vpc.shopease_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "shopease-bastion-sg"
  }
}

# Web Server SG
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow HTTP and SSH from bastion"
  vpc_id      = aws_vpc.shopease_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "shopease-web-sg"
  }
}

# Backend SG
resource "aws_security_group" "backend_sg" {
  name        = "backend-sg"
  description = "Allow app and DB access internally"
  vpc_id      = aws_vpc.shopease_vpc.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "shopease-backend-sg"
  }
}

#------------------------
# 4. EC2 Instances
#------------------------

# Bastion Host
resource "aws_instance" "bastion" {
  ami                    = "ami-0c2b8ca1dad447f8a"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet_1.id
  key_name               = aws_key_pair.bastion_key.key_name
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  tags = {
    Name = "shopease-bastion-host"
  }
}

# Web Servers
resource "aws_instance" "web1" {
  ami                    = "ami-0c2b8ca1dad447f8a"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet_1.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  tags = {
    Name = "shopease-web-server-1"
  }
}

resource "aws_instance" "web2" {
  ami                    = "ami-0c2b8ca1dad447f8a"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet_2.id
  vpc_security_group_ids = [aws_security_group.web_sg.id]
  tags = {
    Name = "shopease-web-server-2"
  }
}

# Backend Servers (RDS will be used instead)

#------------------------
# 5. RDS (MySQL)
#------------------------
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "shopease-db-subnet-group"
  subnet_ids = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]

  tags = {
    Name = "shopease-db-subnet-group"
  }
}

resource "aws_db_instance" "shopease_rds" {
  identifier         = "shopease-db"
  engine             = "mysql"
  engine_version     = "8.0"
  instance_class     = "db.t3.micro"
  username           = "admin"
  password           = "password1234"
  allocated_storage  = 20
  storage_type       = "gp2"
  publicly_accessible = false
  skip_final_snapshot = true
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.backend_sg.id]

  tags = {
    Name = "shopease-db-instance"
  }
}

#------------------------
# 6. Load Balancer (ALB)
#------------------------
resource "aws_lb" "alb" {
  name               = "shopease-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_sg.id]
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]

  tags = {
    Name = "shopease-alb"
  }
}

#------------------------
# 7. CloudWatch Logs
#------------------------
resource "aws_cloudwatch_log_group" "app_log_group" {
  name              = "/shopease/app"
  retention_in_days = 14
  tags = {
    Name = "shopease-app-logs"
  }
}
resource "aws_cloudwatch_log_stream" "app_log_stream" {
  name           = "app-log-stream"
  log_group_name = aws_cloudwatch_log_group.app_log_group.name
}
