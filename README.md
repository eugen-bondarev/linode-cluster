# Deploying the cloud infrastructure

First, review:

`terraform -chdir="cloud" plan -var-file="terraform.tfvars" -out plan`

Then apply the changes:

`terraform -chdir="cloud" apply -auto-approve`

# Deploying the cluster

Review:

`terraform -chdir="cluster" plan -var-file="variables.secret.tfvars"`

Apply the changes:

`terraform -chdir="cluster" apply plan -auto-approve`
