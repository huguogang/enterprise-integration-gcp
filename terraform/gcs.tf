# "inbox" bucket holds uploaded data files.
resource "google_storage_bucket" "inbox" {
  name     = "developertips-ei-inbox"
  location = "us-west2"

  force_destroy = false
  storage_class = "REGIONAL"
  
  lifecycle_rule {
      action {
          type = "Delete"
      }
      condition {
          age = 100
      }
  }
}

# "error" bucket holds data files from the inbox that are either not retriable or have exhausted retries.
resource "google_storage_bucket" "error" {
  name     = "developertips-ei-error"
  location = "us-west2"

  force_destroy = false
  storage_class = "REGIONAL"
  
  lifecycle_rule {
      action {
          type = "Delete"
      }
      condition {
          age = 1000
      }
  }
}

# "archive" bucket holds data files that are processed successfully.
resource "google_storage_bucket" "archive" {
  name     = "developertips-ei-archive"
  location = "us-west2"

  force_destroy = false
  storage_class = "REGIONAL"
  
  # Archive file can progress to near line, cold line then deleted
  lifecycle_rule {
      action {
          type = "SetStorageClass"
          storage_class = "COLDLINE"
      }
      condition {
          age = 100
      }
  }

  lifecycle_rule {
      action {
          type = "Delete"
      }
      condition {
          age = 200
      }
  }
}

#############################################
# Setup Cloud Pub/Sub Change Notification for inbox bucket.
#############################################
resource "google_pubsub_topic" "inbox" {
    name = "ei-inbox"
}

# Special Google Cloud Storage service account.
data "google_storage_project_service_account" "gcs_account" {}

resource "google_pubsub_topic_iam_binding" "binding" {
    topic       = "${google_pubsub_topic.inbox.name}"
    role        = "roles/pubsub.publisher"
    members     = ["serviceAccount:${data.google_storage_project_service_account.gcs_account.email_address}"]
}

resource "google_storage_notification" "notification" {
    bucket            = "${google_storage_bucket.inbox.name}"
    payload_format    = "JSON_API_V1"
    topic             = "${google_pubsub_topic.inbox.name}"
    # Only need to be notified when a new object is successfully uploaded.
    event_types       = ["OBJECT_FINALIZE"]
    depends_on        = ["google_pubsub_topic_iam_binding.binding"]
}

#############################################
# A cloud function that is triggered on new files uploaded to inbox.
#############################################
resource "google_cloudfunctions_function" "inbox" {
  name                  = "ei-inbox-function"
  description           = "Handles new files uploaded to inbox."
  runtime               = "nodejs10"
  available_memory_mb   = 128

  source_archive_bucket = "${google_storage_bucket.ei_source.name}"
  source_archive_object = "${google_storage_bucket_object.ei_inbox_function_zip.name}"
  
  entry_point           = "handleInboxNotification"
  event_trigger {
      event_type = "google.pubsub.topic.publish"
      resource = "${google_pubsub_topic.inbox.name}"
      failure_policy {
          # Disable Cloud Function's retry. For this integration pipeline, retry is controlled by Cloud Pub/Sub.
          # As long as Cloud Function do not ACK the message, CPS will keep retrying for about 2 weeks.
          retry = false
      }
  }
}

# Archive cloud function source code in zip file.
data "archive_file" "ei_inbox_function_zip" {
 type        = "zip"
 source_dir  = "${path.root}/ei-inbox-function/"
 output_path = "${path.root}/depoly/ei-inbox-function.zip"
}

# Bucket for the source code
resource "google_storage_bucket" "ei_source" {
  name   = "developertips-ei-source"
  location = "us-west2"

  force_destroy = false
  storage_class = "REGIONAL"
  
  lifecycle_rule {
      action {
          type = "Delete"
      }
      condition {
          age = 1
      }
  }
}

# Store the cloud function source code in GCS.
resource "google_storage_bucket_object" "ei_inbox_function_zip" {
 # To ensure Cloud Function picks up new code. File name need to be updated for each new version.
 # This is workaround suggested in: https://github.com/terraform-providers/terraform-provider-google/issues/1938
 name   = "ei-inbox-function.${data.archive_file.ei_inbox_function_zip.output_md5}.zip"
 bucket = "${google_storage_bucket.ei_source.name}"
 source = "${data.archive_file.ei_inbox_function_zip.output_path}"
}