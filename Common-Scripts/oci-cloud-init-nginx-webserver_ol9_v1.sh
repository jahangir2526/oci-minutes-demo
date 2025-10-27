#!/bin/bash
echo "Installing nginx" >> /tmp/cloud-init.out
dnf install -y nginx

echo "Starting/Enabling nginx" >> /tmp/cloud-init.out
systemctl enable nginx
systemctl start nginx

echo "Adding firewall rules" >> /tmp/cloud-init.out
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-service=https
firewall-cmd --reload

cd /usr/share/nginx/html
sudo mkdir /tmp/my-nginx-bkp
sudo mv /usr/share/nginx/html/* /tmp/my-nginx-bkp

echo "<style> body {background-color: blue; text-align: center; color: white}</style>" > index.html
echo "<h1>Welcome to nginx Web Server</h1><hr>" > index.html
echo "<h1>Host Name: $(curl -s http://169.254.169.254/opc/v1/instance/ | jq '.hostname') </h1><hr>" >> index.html
echo "<h2>Running on region: $(curl -s http://169.254.169.254/opc/v1/instance/ | jq '.timeCreated') </h2><hr>" >> index.html
echo "<h2>Running on region: $(curl -s http://169.254.169.254/opc/v1/instance/ | jq '.region') </h2><hr>" >> index.html
echo "<h3>Public IP: $(curl -s https://api.ipify.org) </h3><hr>" >> index.html
echo "nginx installation completed" >> /tmp/cloud-init.out
