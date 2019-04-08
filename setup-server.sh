
#!/usr/bin/env bash
source ./utils.sh

set -e
set -o pipefail


trap "$(print_error $LINENO)" EXIT


APPNAME=$1
SQL_ROOT_PASSWORD=$2
DB_NAME=$3
DB_PASSWORD=$4

function create_instance {
  info '<========= Creating VM Instance =========>'
  gcloud compute instances create $APPNAME \
    --zone europe-west1-b \
    --machine-type f1-micro

  info '<========= Adding tag to VM Instance =========>'  
  gcloud compute instances add-tags $APPNAME \
    --tags http-server

  echo 'Successfully provisioned host instance.'
  success '<========= VM Instance Created Successfully =========>'
}


function provision_the_instance {
  info '<========= Provisioning Instance with deployment script =========>'

  gcloud compute scp './deploy-wordpress.sh' $APPNAME:/tmp/deploy-wordpress.sh
  gcloud compute ssh $APPNAME --zone europe-west1-b \
    --command "sudo mv /tmp/deploy-wordpress.sh /home/deploy-wordpress.sh"

  info '<========= Provisioning Instance with Utility script =========>'
  gcloud compute scp './utils.sh' $APPNAME:/tmp/utils.sh
  gcloud compute ssh $APPNAME --zone europe-west1-b \
    --command "sudo mv /tmp/utils.sh /home/utils.sh"
  
  success '<========= VM Instance Provisioned Successfully =========>'
}



function deploy_lamp_application {
  info "<========== Running Deployment Script =========>"
  gcloud compute ssh $APPNAME --zone europe-west1-b \
    --command "chmod +x /home/deploy-wordpress.sh"

  gcloud compute ssh $APPNAME --zone europe-west1-b \
    --command "/home/deploy-wordpress.sh ${SQL_ROOT_PASSWORD} ${DB_NAME} ${DB_PASSWORD}"
}


function main {
  create_instance
  provision_the_instance
  deploy_lamp_application
}

main "$@"