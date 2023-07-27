# Deploying the cloud infrastructure

Initialize:

`terraform -chdir="cloud" init`

First, review:

`terraform -chdir="cloud" plan -var-file="terraform.tfvars"`

Then apply the changes:

`terraform -chdir="cloud" apply -auto-approve`

# Deploying the cluster

Initialize:

`terraform -chdir="cluster" init`

`terraform -chdir="cloud" output -raw kubeconfig | base64 -d > ./cluster/secrets/kubeconfig`

Review:

`terraform -chdir="cluster" plan -var-file="variables.secret.tfvars"`

Apply the changes:

`terraform -chdir="cluster" apply -auto-approve`
