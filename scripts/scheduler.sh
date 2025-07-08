#!/bin/bash
# Get the current project ID
PROJECT_ID=$(gcloud config get-value project)

# Define environment variables
# These variables should be set in your environment before running the script.
: "${CLOUD_FUNCTION_URL:?Environment variable CLOUD_FUNCTION_URL must be set}"
: "${JOB_NAME:?Environment variable JOB_NAME must be set}"
: "${JOB_LOCATION:?Environment variable JOB_LOCATION must be set}"

# Define the job schedule interval in minutes. Defaults to 60 minutes (hourly).
JOB_INTERVAL_MINUTES=${JOB_INTERVAL_MINUTES:-60}
# The gcloud --schedule flag supports the App Engine cron format, which allows for
# human-readable schedules like "every 5 minutes". This is more flexible than
# standard cron syntax.
JOB_SCHEDULE="every ${JOB_INTERVAL_MINUTES} minutes"
SERVICE_ACCOUNT_EMAIL="scheduler-invoker-sa@$PROJECT_ID.iam.gserviceaccount.com"

# Check if the job already exists
JOB_EXISTS=$(gcloud scheduler jobs describe "$JOB_NAME" --location="$JOB_LOCATION" --format="value(name)" 2>/dev/null)

if [ -z "$JOB_EXISTS" ]; then
  # Job doesn't exist, create it
  echo "Creating Cloud Scheduler job: $JOB_NAME"
  gcloud scheduler jobs create http "$JOB_NAME" \
      --schedule="$JOB_SCHEDULE" \
      --location="$JOB_LOCATION" \
      --http-method=POST \
      --uri="$CLOUD_FUNCTION_URL" \
      --oidc-service-account-email="$SERVICE_ACCOUNT_EMAIL"
else
  # Job already exists, update it
  echo "Updating Cloud Scheduler job: $JOB_NAME"
  gcloud scheduler jobs update http "$JOB_NAME" \
      --schedule="$JOB_SCHEDULE" \
      --location="$JOB_LOCATION" \
      --http-method=POST \
      --uri="$CLOUD_FUNCTION_URL" \
      --oidc-service-account-email="$SERVICE_ACCOUNT_EMAIL"
fi

echo "Done"
