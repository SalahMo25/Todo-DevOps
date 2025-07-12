variable "region" {
  default = "us-east-1"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "existing_public_subnet_id" {
  description = "The subnet already used by the EC2 agent (manually created)"
  default     = "subnet-0646a5b0d9e68c656"  # Replace with your real ID
}

variable "my_ip" {
  description = "Your public IP address to allow SSH"
  default     = "154.182.42.166/32"
}

variable "instance_type" {
  default = "t3.small"
}

variable "key_name" {
  default = "devops-key"
}

variable "new_public_subnet_cidrs" {
  default = ["10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24"]
}