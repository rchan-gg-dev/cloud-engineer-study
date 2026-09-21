#!/bin/bash

dnf install -y httpd

echo '<h1>Terraform Public EC2 - User Data</h1>' > /var/www/html/index.html

systemctl enable --now httpd