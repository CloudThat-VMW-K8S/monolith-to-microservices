
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical AWS Marketplace Account ID
}

resource "aws_instance" "ec2_instance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name = var.key_name
  associate_public_ip_address = true
  subnet_id           = var.public_subnet_id
  vpc_security_group_ids = [var.security_group_ids]
  root_block_device {
    volume_size = var.storage_size
    volume_type = var.volume_type
  }
 iam_instance_profile = var.k8sEC2InstanceProfile
  user_data =  base64encode(file("${var.user_data_script_path}")) #file(var.user_data_script_path)

  tags = {
    Name = var.ec2_instance_name
    "kubernetes.io/cluster/k8s" = "owned"
  }
}
