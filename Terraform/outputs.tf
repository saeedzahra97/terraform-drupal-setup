output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "rds_endpoint" {
  value = aws_db_instance.drupal.endpoint
}

output "rds_instance_id" {
  value = aws_db_instance.drupal.id
}

output "ec2_instance_id" {
  value = aws_instance.drupal.id
}