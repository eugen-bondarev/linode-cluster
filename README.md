# Deploying the cluster

```
terraform -chdir="cluster" apply -var-file="variables.secret.tfvars" -replace="helm_release.portfolio" -auto-approve
```
