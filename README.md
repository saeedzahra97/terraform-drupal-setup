# Terraform Drupal Setup

This project contains a Terraform configuration for setting up a scalable Drupal site using AWS services. The setup includes an EC2 instance for the web server, an RDS instance for the database, and an Application Load Balancer (ALB) to distribute traffic.

## Project Overview
The purpose of this project is to provide a reproducible and automated deployment process for a Drupal application. It leverages Infrastructure as Code (IaC) with Terraform, ensuring that all resources are provisioned consistently and efficiently.

### AWS Resources
- **Amazon VPC**: A Virtual Private Cloud (VPC) to host the network infrastructure.
- **Subnets**: Three public and three private subnets to segment the architecture.
- **EC2 Instance**: Amazon Linux 2023 running the Drupal application.
- **RDS (MySQL)**: A managed MySQL database for storing Drupal data.
- **Application Load Balancer**: Distributes incoming HTTP/HTTPS traffic to the EC2 instances.
- **Auto Scaling Group**: Ensures that the EC2 instances scale based on traffic load.
- **Security Groups**: Firewall rules to allow or deny specific traffic.

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

1. **Clone the Repository**: 
   - Go to your terminal and clone the repository by copying the URL of your repository from GitHub. Use a Git client to clone it to your local machine, then navigate into the project directory.

2. **Initialize Terraform**: 
   - Run the command to initialize Terraform, which prepares your environment by downloading the necessary provider plugins.

3. **Review the Deployment Plan**: 
   - Execute the command to see the execution plan for your Terraform configuration. This step shows you what resources will be created, modified, or destroyed.

4. **Apply the Configuration**: 
   - Run the command to apply the configuration and create the resources. When prompted, confirm the action by typing "yes."

5. **Post-Deployment**: 
   - After deployment, take note of the output values displayed, such as the EC2 instance ID and RDS endpoint.

6. **Access Your Drupal Site**: 
   - Use the public IP address or DNS name of the EC2 instance to access your Drupal site. During the initial setup, configure Drupal using the RDS database credentials provided.

### Cleanup

7. **Remove Resources**: 
   - To remove all resources created by Terraform, execute the command that destroys all resources in your configuration.

### Author
**Saeed Zahra**

### Acknowledgments
- **Terraform**
- **AWS**
- **Drupal**

### Troubleshooting
If you encounter issues, check the **AWS Management Console** for logs related to your **EC2** and **RDS** instances. Ensure your **AWS credentials** are correctly configured, and verify that the **AMI ID** is available in the selected region.

For additional resources, consult the documentation for **Terraform**, **AWS RDS**, and **Drupal**.
