#! /bin/bash
# updating the apt-get package 
apt-get update
# installing nginx
apt-get -y install nginx 
apt update
# installing nodejs
apt install nodejs -y
# installing npm
apt install npm -y 


mkdir /app-todo
cd /app-todo
# copying the app files from cloud storage to gce instance
gsutil cp -r gs://nanna-gowri-gce/code/* .
# installing process manager module to automate the deployment process
npm i -g pm2
npm i 
pm2 start app.js --name todo 
# copying the nginx.conf file from cloud storage to required location
# this enables nginx to act as a reverse proxy on port 80 and serve nodejs  website as a response
gsutil cp gs://nanna-gowri-gce/conf/nginx.conf /etc/nginx/nginx.conf
# restarting the nginx service to reflect the changes
service nginx restart

