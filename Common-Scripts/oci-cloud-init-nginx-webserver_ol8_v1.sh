#!/bin/bash
echo "Installing nginx" >> /tmp/cloud-init.out
dnf install nginx -y
echo "Starting/Enabling nginx" >> /tmp/cloud-init.out
systemctl enable --now nginx.service
systemctl status nginx

echo "Stopping firewalld" >> /tmp/cloud-init.out
systemctl stop firewalld

echo "Creating a server-info.html file" >> /tmp/cloud-init.out
cd /usr/share/nginx/html/
echo "<h1>Welcome to nginx Web Server</h1><hr>" > server-info.html
echo "<h1>Host Name: $(curl -s http://169.254.169.254/opc/v1/instance/ | jq '.hostname') </h1><hr>" >> server-info.html
echo "<h2>Running on region: $(curl -s http://169.254.169.254/opc/v1/instance/ | jq '.region') </h2><hr>" >> server-info.html
echo "<h3>Public IP: $(curl -s https://api.ipify.org) </h3><hr>" >> server-info.html
echo "<h4>Random Name: $(curl -s http://names.drycodes.com/1?format=text&case=upper) </h4>" >> server-info.html
echo "nginx installation completed" >> /tmp/cloud-init.out
