output "k8sec2_iam_role_arn" {
  value       = aws_iam_role.k8sec2.arn
  description = "ARN of the IAM role"
}
output "k8sEC2InstanceProfile" {
  value = aws_iam_instance_profile.ec2_instance_profile.name
}