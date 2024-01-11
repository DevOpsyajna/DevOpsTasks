#!/bin/bash
sudo apt update
sudo apt install apache2 -y
sudo echo "<h1>Hello Netzary Infodynamics, I'm Yajna</h1>" > /var/www/html/index.html
