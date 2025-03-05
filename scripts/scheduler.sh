#!/bin/bash
# Get the current project ID
PROJECT_ID=$(gcloud config get-value project)

# Define environment variables
CLOUD_FUNCTION_URL="REPLACE_WITH_CLOUD_FUNCTION_URL"
JOB_NAME="update-dns-records-job"
JOB_LOCATION="us-central1"
JOB_SCHEDULE="0 * * * *"
SERVICE_ACCOUNT_EMAIL="scheduler-invoker-sa@$PROJECT_ID.iam.gserviceaccount.com"

# Check if the job already exists
JOB_EXISTS=$(gcloud scheduler jobs describe $JOB_NAME --location=$JOB_LOCATION --format="value(name)" 2>/dev/null)

if [ -z "$JOB_EXISTS" ]; then
  # Job doesn't exist, create it
  echo "Creating Cloud Scheduler job: $JOB_NAME"
  gcloud scheduler jobs create http $JOB_NAME \
      --schedule="$JOB_SCHEDULE" \
      --location=$JOB_LOCATION \
      --http-method=POST \
      --uri=$CLOUD_FUNCTION_URL \
      --oidc-service-account-email=$SERVICE_ACCOUNT_EMAIL
else
  # Job already exists, update it
  echo "Updating Cloud Scheduler job: $JOB_NAME"
  gcloud scheduler jobs update http $JOB_NAME \
      --schedule="$JOB_SCHEDULE" \
      --location=$JOB_LOCATION \
      --http-method=POST \
      --uri=$CLOUD_FUNCTION_URL \
      --oidc-service-account-email=$SERVICE_ACCOUNT_EMAIL
fi

echo "Done"
