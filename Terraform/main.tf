# VPC Configuration
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "Drupal VPC"
  }
}

# Define hardcoded Availability Zones
locals {
  availability_zones = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Drupal VPC Internet Gateway"
  }
}

# Route Table for Public Subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

# Public Subnets
resource "aws_subnet" "public" {
  count             = 3
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.public_subnets, count.index)
  availability_zone = local.availability_zones[count.index]

  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet ${count.index + 1}"
  }
}

# Associate Route Table with Public Subnets
resource "aws_route_table_association" "public" {
  count          = 3
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

# Private Subnets
resource "aws_subnet" "private" {
  count             = 3
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.private_subnets, count.index)
  availability_zone = local.availability_zones[count.index]

  tags = {
    Name = "Private Subnet ${count.index + 1}"
  }
}

# Security Group for EC2 Instance
resource "aws_security_group" "drupal_ec2_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "Drupal EC2 SG"
    Description = "Security Group for accessing Drupal Instance"
  }
}

# Security Group for RDS Instance
resource "aws_security_group" "drupal_rds_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.drupal_ec2_sg.id]  # Allows traffic from the EC2 instances' security group
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allows outbound traffic to anywhere
  }

  tags = {
    Name = "Drupal RDS SG"
  }
}

# Subnet Group for RDS
resource "aws_db_subnet_group" "main" {
  name       = "drupal-db-subnet-group"
  subnet_ids = aws_subnet.private.*.id

  tags = {
    Name = "Drupal DB Subnet Group"
  }
}
# Retrieve RDS Credentials from AWS Secrets Manager
data "aws_secretsmanager_secret_version" "rds_creds" {
  secret_id = "arn:aws:secretsmanager:eu-central-1:975050117585:secret:rds-db-Utq20E"
}

# Extract the credentials from the secret string
locals {
  rds_credentials = jsondecode(data.aws_secretsmanager_secret_version.rds_creds.secret_string)
}

# RDS Instance
resource "aws_db_instance" "drupal" {
  identifier              = var.db_instance_identifier
  engine                  = "mysql"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  db_subnet_group_name    = aws_db_subnet_group.main.name

  username = local.rds_credentials["username"]
  password = local.rds_credentials["password"]
  db_name  = var.db_name

  vpc_security_group_ids  = [aws_security_group.drupal_rds_sg.id]
  apply_immediately       = true
  skip_final_snapshot     = true
  publicly_accessible     = false
  storage_type            = "gp2"
  backup_retention_period = 0

  tags = {
    Name = "Drupal RDS"
  }
}

# EC2 Instance
resource "aws_instance" "drupal" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.drupal_ec2_sg.id]

  ebs_block_device {
    device_name = "/dev/xvda"
    volume_type = "gp2"
    volume_size = 20
  }

    user_data = file("install_drupal.sh")


  tags = {
    Name = "My-Drupal-Instance"
  }
}

# EC2 Launch Template
resource "aws_launch_template" "drupal_lt" {
  name          = "drupal-launch-template"
  image_id       = var.ami_id
  instance_type  = var.instance_type

  network_interfaces {
    associate_public_ip_address = true
    security_groups = [aws_security_group.drupal_ec2_sg.id]
  }

  user_data = base64encode(file("install_drupal.sh"))

  tags = {
    Name = "Drupal Launch Template"
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "drupal_asg" {
  launch_template {
    id      = aws_launch_template.drupal_lt.id
    version = "$Latest"
  }

  min_size             = 1
  max_size             = 3
  desired_capacity     = 1
  vpc_zone_identifier  = aws_subnet.public[*].id
  target_group_arns    = [aws_lb_target_group.app_tg.arn]

  tag {
    key                 = "Name"
    value               = "Drupal ASG Instance"
    propagate_at_launch = true
  }
}

# Application Load Balancer
resource "aws_lb" "app_lb" {
  name               = "drupal-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.drupal_ec2_sg.id]
  subnets            = aws_subnet.public.*.id

  tags = {
    Name = "Drupal ALB"
  }
}

# Target Group for ALB
resource "aws_lb_target_group" "app_tg" {
  name     = "app-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id

 health_check {
    path                = "/index.php"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "Drupal Target Group"
  }
}

# ALB Listener
resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_tg.arn
  }
}