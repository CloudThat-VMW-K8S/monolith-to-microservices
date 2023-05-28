locals {

  region                = "ap-south-1"

  #vpc

  vpc_cidr_block        = "10.0.0.0/16"
  public_subnet_cidrs   = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs  = ["10.0.3.0/24", "10.0.4.0/24"]
  vpc_name              = "Ansible Automation"
  subnet_names          = ["Public-Subnet-1", "Public-Subnet-2", "Private-Subnet-1", "Private-Subnet-2"]

  #EC2

  instance_type         = "t3.medium"
  storage_size          = 30
  http_port             = 80
  ssh_port              = 22
  user_data_script_path = "./scripts/k8s-cluster-v1-24-4-single-node-setup.sh"
  ec2_instance_name     = "Ansible Automation Controller"
  key_name  = "ca_ap_s1"
  volume_type           = "gp3"
  ingress_cidr_block    = "0.0.0.0/0"

  # iam
  k8sec2_role_name = "K8sClusterCreationRole"
  k8sec2_iam_policy_file = "./scripts/k8sec2iampolicy.json"
  k8sec2_policy_name = "K8sClusterCreationPolicy"
  instance_profile_name = "K8sEC2InstanceProfile"
}
