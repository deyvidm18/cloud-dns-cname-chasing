#!/bin/bash
# Get the current project ID
PROJECT_ID=$(gcloud config get-value project)

# Function to check if a service account exists
service_account_exists() {
  local sa_email="$1"
  gcloud iam service-accounts describe "$sa_email" --project="$PROJECT_ID" &>/dev/null
  return $?
}

# Service account for Cloud Function (DNS Editor)
DNS_UPDATER_SA="dns-updater-sa@$PROJECT_ID.iam.gserviceaccount.com"
if ! service_account_exists "$DNS_UPDATER_SA"; then
  echo "Creating DNS Updater Service Account: dns-updater-sa"
  gcloud iam service-accounts create dns-updater-sa \
      --display-name="DNS Updater Service Account"
else
  echo "DNS Updater Service Account already exists: dns-updater-sa"
fi

# Service account for Cloud Scheduler (Cloud Functions Invoker)
SCHEDULER_INVOKER_SA="scheduler-invoker-sa@$PROJECT_ID.iam.gserviceaccount.com"
if ! service_account_exists "$SCHEDULER_INVOKER_SA"; then
  echo "Creating Scheduler Invoker Service Account: scheduler-invoker-sa"
  gcloud iam service-accounts create scheduler-invoker-sa \
      --display-name="Scheduler Invoker Service Account"
else
  echo "Scheduler Invoker Service Account already exists: scheduler-invoker-sa"
fi

# Create the Cloud Build service account
CLOUD_BUILD_SA="cloud-build-sa@$PROJECT_ID.iam.gserviceaccount.com"
if ! service_account_exists "$CLOUD_BUILD_SA"; then
  echo "Creating Cloud Build Service Account: cloud-build-sa"
  gcloud iam service-accounts create cloud-build-sa \
      --display-name="Cloud Build Service Account"
else
  echo "Cloud Build Service Account already exists: cloud-build-sa"
fi

# Grant DNS Editor role to the Cloud Function service account
gcloud projects add-iam-policy-binding "$PROJECT_ID" \
    --member="serviceAccount:dns-updater-sa@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/dns.admin"

# Grant Cloud Functions Invoker role to the Cloud Scheduler service account
gcloud projects add-iam-policy-binding "$PROJECT_ID" \
    --member="serviceAccount:scheduler-invoker-sa@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/run.invoker"

# Grant Cloud Build Builds Builder role to the Build service account
gcloud projects add-iam-policy-binding "$PROJECT_ID" \
    --member="serviceAccount:cloud-build-sa@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/cloudbuild.builds.builder"

# Grant Cloud Run Builder role to the Build service account
gcloud projects add-iam-policy-binding "$PROJECT_ID" \
    --member="serviceAccount:cloud-build-sa@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/run.builder"

echo "Done"
