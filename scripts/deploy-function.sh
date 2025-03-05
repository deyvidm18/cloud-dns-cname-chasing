#!/bin/bash
# Get the current project ID
PROJECT_ID=$(gcloud config get-value project)

# Define environment variables
ZONE_NAME="REPLACE_WITH_ZONE_NAME"
DNS_NAME="REPLACE_WITH_DNS_NAME"
CNAME_TARGET="REPLACE_WITH_CNAME_TARGET"

# Deploy the Cloud Function
gcloud functions deploy update-dns-records \
    --source ../function/ \
    --region us-central1 \
    --entry-point update_dns_records \
    --runtime python310 \
    --build-service-account="projects/$PROJECT_ID/serviceAccounts/cloud-build-sa@$PROJECT_ID.iam.gserviceaccount.com" \
    --trigger-http \
    --gen2 \
    --ingress-settings=internal-only \
    --service-account="dns-updater-sa@$PROJECT_ID.iam.gserviceaccount.com" \
    --set-env-vars="PROJECT_ID=$PROJECT_ID,ZONE_NAME=$ZONE_NAME,DNS_NAME=$DNS_NAME,CNAME_TARGET=$CNAME_TARGET"