#! /bin/bash
echo "WE ARE ABOUT TO DEPLOY THE TODO LIST WEBSITE ON GOOGLE COMPUTE ENGINE"
echo "ENTER YOUR GOOGLE CLOUD PROJECT ID"
read PROJECT_ID
gcloud config set project $PROJECT_ID
# ENABLING THE GOOGLE COMPUTE ENGINE API 
echo "STEP ➊:-"
echo "ENABLING THE COMPUTE ENGINE API "
gcloud services enable compute.googleapis.com 
echo "SUCCESFULLY ENABLED THE COMPUTE ENGINE API"


BUCKET_NAME=$PROJECT_ID-gce 
sed -i s/GOOGLE_CLOUD_STORAGE_BUCKET_NAME/$BUCKET_NAME/  gce-startup-script.sh 
# CREATING THE GOOGLE CLOUD STORAGE BUCKET TO STORE APP FILES
echo "STEP ➋:-"
echo "CREATING THE GOOGLE CLOUD STORAGE BUCKET TO STORE APP FILES"

gsutil mb  -l asia-south2 gs://$BUCKET_NAME
# COPYING THE FILES TO CLOUD STORAGE
echo "STEP ➌:-"
echo "COPYING THE APP FILES FROM LOCAL STORAGE TO CLOUD STORAGE BUCKET NAMED ${BUCKET_NAME}"
gsutil cp -r code gs://$BUCKET_NAME/ 
gsutil cp -r conf gs://$BUCKET_NAME/
# CREATING NETWORK NAMED network-todo
echo "STEP ➍:-"
echo "CREATING THE VPC NETWORK NAMED network-todo"
gcloud compute networks create network-todo  --subnet-mode custom
echo "SUCCESSFULLY CREATED THE network-todo  NETWORK"
# CREATING SUBNETS IN REGION asia-south2 IN NETWORK network-todo
echo "STEP ➎:-"
echo "CREATING THE SUBNET NAMED subnet-todo-asia in NETWORK network-todo"
gcloud compute networks subnets create subnet-todo-asia --region asia-south2 --network network-todo  --range 192.168.0.0/22
echo "SUBNET CREATION COMPLETED"
# CREATING THE FIREWALL-RULES TO ALLOW SSH,HTTP CONNECTIONS 
echo "STEP ➏:-"
echo "CREATING FIREWALL-RULES TO ALLOW INCOMING CONNECTIONS SUCH AS SSH,HTTP REQUESTS"
gcloud compute firewall-rules create allow-ssh --allow tcp:22 --network network-todo
gcloud compute firewall-rules create allow-http  --target-tags allow-http --allow tcp:80  --network network-todo 
echo "CREATING THE GOOGLE COMPUTE INSTANCE TO RUN OUR CODE "
# CREATING THE COMPUTE INSTANCE
echo "STEP ➐:-"
gcloud compute instances create todo-website --zone asia-south2-a --machine-type n1-standard-2 \
--image-project ubuntu-os-cloud \
--image-family ubuntu-2204-lts \
--metadata-from-file=startup-script=./gce-startup-script.sh \
--metadata=serial-port-enable=True \
--network network-todo \
--subnet subnet-todo-asia \
--tags allow-http
echo "SUCESSFULLY CREATED THE COMPUTE INSTANCE"
EXTERNAL_IP=$(gcloud compute instances describe todo-website --zone asia-south2-a --format "value(networkInterfaces[0].accessConfigs[0].natIP)")
echo "SETUP COMPLETED 👍"
echo "PLEASE GO THROUGH THIS URL TO ACCESS THE WEBSITE AFTER 2-3 MINUTES"
echo "URL :  http://${EXTERNAL_IP}"

