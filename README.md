# Deploying the cluster

```
terraform -chdir="cluster" apply -var-file="variables.secret.tfvars" -auto-approve
```
