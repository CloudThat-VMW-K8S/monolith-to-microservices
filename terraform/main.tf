terraform {
    /**cloud {
	     organization = local.organization
	       workspaces {
  	name = local.workspaces
	}
  }**/
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region            = local.region
}



module "vpc" {
  source = "./modules/vpc"

  vpc_cidr_block       = local.vpc_cidr_block
  public_subnet_cidrs  = local.public_subnet_cidrs
  private_subnet_cidrs = local.private_subnet_cidrs
  vpc_name             = local.vpc_name
  subnet_names         = local.subnet_names
}

module "iam" {
  source = "./modules/iam"
  k8sec2_iam_policy_file = local.k8sec2_iam_policy_file
  k8sec2_role_name = local.k8sec2_role_name
  k8sec2_policy_name = local.k8sec2_policy_name
  instance_profile_name = local.instance_profile_name


  
}


module "ec2" {
  source = "./modules/ec2"

  vpc_id                = module.vpc.vpc_id
  public_subnet_id = module.vpc.public_subnet_id
  instance_type         = local.instance_type
  key_name = local.key_name
  ec2_instance_name     = local.ec2_instance_name
  storage_size          = local.storage_size
  volume_type           = local.volume_type
  user_data_script_path = local.user_data_script_path
  security_group_ids    = module.sg.ec2_sg_id
  k8sEC2InstanceProfile = module.iam.k8sEC2InstanceProfile
}

module "sg" {
  source = "./modules/sg"

  vpc_id = module.vpc.vpc_id
  #ec2_sg_id     = module.sg.ec2_sg_id
  http_port          = local.http_port
  ssh_port           = local.ssh_port
  ingress_cidr_block = local.ingress_cidr_block
}
