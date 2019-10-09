# enterprise-integration-gcp

Enterprise Integration using Google Cloud Platform products. Companion 
artiles with in depth discussion: 
http://developertips.blogspot.com/search/label/Enterprise%20Integration.

## Deploy GCP Infra

Terraform commands:

```
# Init terraform.
terraform init

# Plan (preview) terraform changes.
terraform plan

# Apply terraform changes.
terraform apply

# Format terraform code.
terraform fmt

# Clean Up
terraform plan -destroy
terraform destroy
```

Sample command to sync tfstate with actual:

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
