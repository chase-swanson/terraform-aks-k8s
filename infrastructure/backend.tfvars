# This is the default backend configuration used for running Terraform locally.
# These values are specified in the pipeline when apply infrastructure in CI/CD.
# To run terraform locally to apply infrastructure changes in the Development
# environment use the command: terraform init -backend-config="backend.tfvars"


# Change comment in or out based on what subscription is needed
storage_account_name = "terraformdbkidev"
# storage_account_name = "terraformdbkiprod"
