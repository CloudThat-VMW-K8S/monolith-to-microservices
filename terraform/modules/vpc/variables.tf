variable "vpc_name" {
  description = "Name of the VPC"
}

variable "subnet_names" {
  description = "Names of the subnets"
  type        = list(string)
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the public subnets"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for the private subnets"
  type        = list(string)
}
