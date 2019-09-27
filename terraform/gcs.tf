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

