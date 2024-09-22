# Terraform Drupal Setup

This project contains a Terraform configuration for setting up a scalable Drupal site using AWS services. The setup includes an EC2 instance for the web server, an RDS instance for the database, and an Application Load Balancer (ALB) to distribute traffic.

## Project Overview
The purpose of this project is to provide a reproducible and automated deployment process for a Drupal application. It leverages Infrastructure as Code (IaC) with Terraform, ensuring that all resources are provisioned consistently and efficiently.



### AWS Resources
- **Amazon VPC**: A Virtual Private Cloud (VPC) to host the network infrastructure.
- **Subnets**: 3 public and 3 private subnets to segment the architecture.
- **EC2 Instance**: Amazon Linux 2023 running the Drupal application.
- **RDS (MySQL)**: A managed MySQL database for storing Drupal data.
- **Application Load Balancer**: Distributes incoming HTTP/HTTPS traffic to the EC2 instances.
- **Auto Scaling Group**: Ensures that the EC2 instances scale based on traffic load.
- **Security Groups**: Firewall rules to allow/deny specific traffic.

### Terraform Configuration
- **`main.tf`**: Defines resources such as EC2, RDS, security groups, and load balancer.
- **`provider.tf`**: Specifies the AWS provider configuration.
- **`variables.tf`**: Defines input variables like instance type, key pair name, etc.
- **`outputs.tf`**: Outputs important information such as EC2 instance IDs and RDS endpoints.

### Prerequisites
- [Terraform](https://www.terraform.io/downloads) installed locally.
- AWS CLI configured with access to your AWS account.
- SSH key for connecting to the EC2 instance (optional for testing).
- AWS credentials with permissions to create resources.

### Instructions for Deployment

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/terraform-drupal-setup.git
   cd terraform-drupal-setup
