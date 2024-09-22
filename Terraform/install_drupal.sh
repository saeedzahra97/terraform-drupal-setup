#!/bin/bash
# Install necessary packages
sudo dnf install -y mariadb105 aws-cli

# Set up the environment variables for the database
export MYSQL_HOST=$(aws rds describe-db-instances --db-instance-identifier drupal --query "DBInstances[0].Endpoint.Address" --output text)

# Log in to MySQL and set up Drupal database
mysql --host="$MYSQL_HOST" --user="$db_username" --password="$db_password" -e "CREATE DATABASE drupal;"

# Fetch the DB credentials from Secrets Manager
DB_CREDENTIALS=$(aws secretsmanager get-secret-value --secret-id arn:aws:secretsmanager:eu-central-1:975050117585:secret:rds-db-Utq20E --query SecretString --output text)

# Extract username and password
DB_USERNAME=$(echo $DB_CREDENTIALS | jq -r .username)
DB_PASSWORD=$(echo $DB_CREDENTIALS | jq -r .password)

# Create a database user
mysql --user="$DB_USERNAME" --password="$DB_PASSWORD" --execute="CREATE USER 'drupal' IDENTIFIED BY 'drupal-pass'; GRANT ALL PRIVILEGES ON drupal.* TO drupal; EXIT;"

# Install and configure Apache
sudo dnf install -y httpd
sed -i '156 s/None/All/' /etc/httpd/conf/httpd.conf
sudo service httpd start

# Install PHP and necessary extensions
sudo dnf install -y php8.2 php-dom php-gd php-simplexml php-xml php-opcache php-mbstring php-mysqlnd

# Download and set up Drupal
sudo wget https://ftp.drupal.org/files/projects/drupal-10.2.6.tar.gz
sudo mv drupal-10.2.6.tar.gz tar.gz
sudo tar -xzf tar.gz
sudo mv drupal-* drupal
cd drupal
sudo rsync -avz . /var/www/html
sudo chown -R apache:apache /var/www/html
sudo service httpd restart