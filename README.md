This project consists of four web applications running inside a Kubernetes cluster on **Linode Cloud**:

- https://eugen-bondarev.com
- https://pipelines.eugen-bondarev.com
- https://metrics.eugen-bondarev.com
- https://infrastructure.eugen-bondarev.com

The entire infrastructure is managed via **Terraform**, it consists of two logical layers:

- **Cloud infrastructure deployment**: <br>
  This layer is responsible for spinning up the machines of the specified type in the specified location, creating a managed Kubernetes cluster on Linode and uploading its configuration to Terraform Cloud for later usage.
- **Application deployment and DNS configuration**: <br>
  This layer is responsible for creating namespaces, configuring and uploading applications to the cluster created in the first layer. For both third-party and my applications I used helm. These are the applications and resources that are deployed to the cluster:
  - Portfolio:
    - [app](https://github.com/eugen-bondarev/portfolio) (config-map, deployment of bedrock and nginx containers, pvc, internal service)
    - db (pvc, mysql container deployment, internal service)
  - Metrics:
    - Two third-party helm charts: Grafana and Prometheus
  - Pipelines:
    - Jenkins helm chart
  - Infrastructure Overview
    - [app](https://github.com/eugen-bondarev/portfolio-infrastructure-overview) (deployment of a next.js app, internal service)
  - Ingress:
    - ingress-nginx helm chart
    - tls secret (tls.crt, tls.key)

The entire Terraform project is located in this repository with all its secrets, which are encrypted using GitCrypt. I wanted to design it in the most practical way with the most straightforward deployment workflow and GitOps principles. The only requirements to deploy any infrastructure changes are reading access to the repo and the key to unlock the secrets.

To examine the deployment process please refer to [.github/workflows/main.yaml](https://github.com/eugen-bondarev/linode-cluster/blob/main/.github/workflows/main.yaml)
