
provider "aws" {
  region = var.region
}

# SSH Key
resource "aws_key_pair" "devops_key" {
  key_name   = var.key_name
  public_key = file("~/.ssh/id_rsa.pub")
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "devops-vpc"
  }
}


# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "devops-igw"
  }
}



resource "aws_subnet" "eks_public" {
  count                   = length(var.new_public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.new_public_subnet_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index + 1] # skip the first AZ (used by EC2)

  tags = {
    Name = "eks-public-subnet-${count.index + 2}"
    "kubernetes.io/role/elb"                       = "1"
    "kubernetes.io/cluster/eks-production-cluster" = "shared"
  }
}

# Route Table for Public Subnets
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "devops-public-rt"
  }
}
resource "aws_route_table_association" "public_assoc" {
  count          = length(var.new_public_subnet_cidrs)
  subnet_id      = aws_subnet.eks_public[count.index].id
  route_table_id = aws_route_table.public_rt.id
}


resource "aws_route_table_association" "public_existing" {
  subnet_id      = var.existing_public_subnet_id
  route_table_id = aws_route_table.public_rt.id
}


# Security Group
resource "aws_security_group" "devops_sg" {
  name        = "devops-agent-sg"
  description = "Allow SSH and outbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "devops-agent-sg"
  }
}
# EC2 Instance
resource "aws_instance" "devops_agent" {
  ami                         = "ami-0c7217cdde317cfec" # Ubuntu 22.04 LTS x86_64 in us-east-1
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.devops_key.key_name
  subnet_id                   = var.existing_public_subnet_id
  vpc_security_group_ids      = [aws_security_group.devops_sg.id]
  associate_public_ip_address = true

  tags = {
    Name = "azure-devops-agent"
  }

  provisioner "local-exec" {
    command = "echo ${self.public_ip} > ec2-ip.txt"
  }
}
# Get AZs
data "aws_availability_zones" "available" {}


