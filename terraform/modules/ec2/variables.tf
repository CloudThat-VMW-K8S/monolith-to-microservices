variable "vpc_id" {
  description = "ID of the VPC"
}

variable "instance_type" {
  description = "Type of the EC2 instance"
}

variable "storage_size" {
  description = "Size of the storage (in GB)"
}

variable "user_data_script_path" {
  description = "User data script for EC2 instance"
}

/**variable "ami_id" {
  description = "AMI ID for the EC2 instance"
}**/

variable "ec2_instance_name" {
  description = "Name of the ec2 instance"
}
variable "volume_type" {
  description = "Volume Type (gp2, gp3 etc.)"
}
variable "security_group_ids" {}
variable "public_subnet_id" {}
variable "key_name" {}
variable "k8sEC2InstanceProfile" {}