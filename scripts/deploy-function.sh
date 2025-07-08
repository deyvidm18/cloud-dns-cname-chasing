#!/bin/bash
# Get the current project ID
PROJECT_ID=$(gcloud config get-value project)

# Define environment variables
# These variables should be set in your environment before running the script.
: "${ZONE_NAME:?Environment variable ZONE_NAME must be set}"
: "${DNS_NAME:?Environment variable DNS_NAME must be set}"
: "${CNAME_TARGET:?Environment variable CNAME_TARGET must be set}"
: "${FUNCTION_NAME:?Environment variable FUNCTION_NAME must be set}"

# Deploy the Cloud Function
gcloud functions deploy "$FUNCTION_NAME" \
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