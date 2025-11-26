Run the bootstrap script to create the Azure storage container for the Terraform backend.

Example:
  cd terraform/bootstrap
  ./bootstrap.sh tfstate-rg eastus myuniquestateacct tfstate <SUBSCRIPTION_ID>

This generates a backend.tfvars file in the parent terraform/ directory.