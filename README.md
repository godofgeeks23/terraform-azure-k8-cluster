# Setting up a Kubernetes cluster with Terraform on Azure

Set up a Kubernetes cluster on Azure using Terraform. This guide will walk you through the process step by step.

## Setup and Usage

1. Authenticate using Azure CLI

```
az login
az account set --subscription "your-subscription-id"
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/<SUBSCRIPTION_ID>"
```

2. Setup env variables

```
$ export ARM_CLIENT_ID="<APPID_VALUE>"
$ export ARM_CLIENT_SECRET="<PASSWORD_VALUE>"
$ export ARM_SUBSCRIPTION_ID="<SUBSCRIPTION_ID>"
$ export ARM_TENANT_ID="<TENANT_VALUE>"
```

3. Run terraform validation checks

```
terraform init
terraform validate
terraform apply
```

To destroy - 

```
terraform destroy
```
