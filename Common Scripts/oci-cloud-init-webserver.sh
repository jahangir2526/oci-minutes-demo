#!/bin/bash
yum -y install httpd
firewall-offline-cmd --permanent --add-port=80/tcp
firewall-offline-cmd --reload

echo "<h1>Welcome to host: $(curl -s http://169.254.169.254/opc/v1/instance/ | jq '.hostname') </h1><hr>" > /var/www/html/index.html
echo "<h2>Running on region: $(curl -s http://169.254.169.254/opc/v1/instance/ | jq '.region') </h2><hr>" >> /var/www/html/index.html
echo "<h3>Public IP: $(curl -s https://api.ipify.org) </h3><hr>" >> /var/www/html/index.html
echo "<h4>Random Name: $(curl -s http://names.drycodes.com/1?format=text&case=upper) </h4>" >> /var/www/html/index.html

systemctl stop firewalld
systemctl disable firewalld
systemctl start httpd
systemctl enable httpd

