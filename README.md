# Deploying the cloud infrastructure

First, review:

`terraform -chdir="cloud" plan -var-file="terraform.tfvars"`

Then apply the changes:

`terraform -chdir="cloud" apply -var-file="terraform.tfvars" -auto-approve`

# Deploying the cluster

Review:

`terraform -chdir="cluster" plan -var-file="variables.secret.tfvars"`

Apply the changes:

`terraform -chdir="cluster" apply -var-file="variables.secret.tfvars" -auto-approve`
