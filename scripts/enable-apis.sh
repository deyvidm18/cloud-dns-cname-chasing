#!/bin/bash
# Enable Cloud Function Service and Wait
OPERATION=$(gcloud services enable cloudfunctions.googleapis.com --format="value(operations.name)")
if [[ -n "$OPERATION" ]]; then
  gcloud services wait-for-operation "$OPERATION" --timeout=300
else
  echo "Cloud Functions API was already enabled."
fi

# Enable Cloud Run Service and Wait
OPERATION=$(gcloud services enable run.googleapis.com --format="value(operations.name)")
if [[ -n "$OPERATION" ]]; then
  gcloud services wait-for-operation "$OPERATION" --timeout=300
else
  echo "Cloud Run API was already enabled."
fi

# Enable Cloud Build Service and Wait
OPERATION=$(gcloud services enable cloudbuild.googleapis.com --format="value(operations.name)")
if [[ -n "$OPERATION" ]]; then
  gcloud services wait-for-operation "$OPERATION" --timeout=300
else
  echo "Cloud Build API was already enabled."
fi

# Enable Cloud Scheduler Service and Wait
OPERATION=$(gcloud services enable cloudscheduler.googleapis.com --format="value(operations.name)")
if [[ -n "$OPERATION" ]]; then
  gcloud services wait-for-operation "$OPERATION" --timeout=300
else
  echo "Cloud Scheduler API was already enabled."
fi