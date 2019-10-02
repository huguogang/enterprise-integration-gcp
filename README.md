# enterprise-integration-gcp
Enterprise Integration on Google Cloud Platform.


## Deploy GCP Infra

Terraform commands:

```
terraform init
terraform plan
terraform apply
```

Sync with state with actual

```
terraform import google_storage_bucket.inbox developertips-ei-inbox
terraform import google_storage_bucket.archive developertips-ei-archive
terraform import google_storage_bucket.error developertips-ei-error
```

## Cloud Function

To view logs

```
gcloud functions logs read
```