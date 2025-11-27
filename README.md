# Azure DevOps Assignment – Microservices on AKS with Terraform & GitHub Actions

This project delivers a complete DevOps implementation using Azure Kubernetes Service (AKS), Terraform, GitHub Actions CI/CD, Azure Container Registry (ACR), Azure Key Vault, and Application Insights + Container Insights for monitoring.

### It implements a small microservices-based application consisting of:

User Service (Python Flask + OpenTelemetry)

Order Service (Python Flask + OpenTelemetry)

API Gateway (Node.js)

Deployed to AKS and fully automated via CI/CD

This submission fulfills all requirements from the assignment.

# 1. Architecture Overview
#### Components Included

Microservices: User Service, Order Service, API Gateway

AKS Cluster: Ingress controller (NGINX), HPA autoscaling

ACR: Docker image registry

Key Vault: Secure secret storage (App Insights Conn String)

Application Insights: Telemetry from microservices (OTel traces)

Container Insights: Cluster metrics, logs, performance

Terraform IaC: AKS, ACR, KV, LA Workspace, Networking

GitHub Actions CI/CD: Build → Scan → Push → Deploy

Service Principal: RBAC-secured deployment identity

# Architecture Diagram:
![AzureAssigmnet01](https://github.com/user-attachments/assets/c3b09183-f102-4ce0-9594-d0dac709bd6e)



# 2. Prerequisites

## Install:

az CLI

terraform

kubectl

docker

GitHub account + repo

Azure subscription (Owner or Contributor access)
<img width="1000" height="679" alt="Screenshot 2025-11-27 at 2 25 42 AM" src="https://github.com/user-attachments/assets/f10b41c1-a082-40ee-bd80-fcce781fb414" />

<img width="1428" height="755" alt="Screenshot 2025-11-27 at 2 28 50 AM" src="https://github.com/user-attachments/assets/a60fba48-9da3-42e6-a3e9-bae3acfa5874" />


# 3. Terraform Infrastructure Deployment

3.1 Bootstrap Terraform Backend

Creates Storage Account + Container for remote state.

```./scripts/bootstrap.sh tfstate-rg eastus mytfstateacct tfstate <SUBSCRIPTION_ID>```
<img width="1232" height="575" alt="Screenshot 2025-11-27 at 2 55 27 AM" src="https://github.com/user-attachments/assets/e44140ca-c8f8-4b51-8611-1cf794e5b378" />

3.2 Initialize & Apply Terraform
```
cd terraform
terraform init -backend-config=backend.tfvars.example
terraform plan -var-file="envs/prod.tfvars"
terraform apply -var-file="envs/prod.tfvars" -auto-approve
```
<img width="1217" height="622" alt="Screenshot 2025-11-27 at 3 00 45 AM" src="https://github.com/user-attachments/assets/291fbcf1-b4c2-4ed8-8626-c6e2e210db34" />
<img width="1239" height="664" alt="Screenshot 2025-11-27 at 3 15 11 AM" src="https://github.com/user-attachments/assets/4f924fa8-532b-4223-b751-a6b164919769" />
<img width="1233" height="731" alt="Screenshot 2025-11-27 at 3 38 47 AM" src="https://github.com/user-attachments/assets/fd57177a-540c-4f7b-830a-3d46232b831e" />

<img width="1209" height="599" alt="Screenshot 2025-11-27 at 3 40 28 AM" src="https://github.com/user-attachments/assets/8e22015b-9b84-4324-a37f-8dc69d227747" />

### Terraform provisions:

AKS Cluster

ACR

Key Vault

Log Analytics Workspace

VNet/Subnets (if defined)

App Insights (optional via module)



# 4. GitHub Actions CI/CD
### 4.1 Create a Service Principal
```
az ad sp create-for-rbac \
  --name "gh-actions-acr-aks" \
  --role Contributor \
  --scopes /subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<AKS_RG> \
  --sdk-auth
```


#### Copy JSON → GitHub Secrets → AZURE_CREDENTIALS.

### 4.2 Required GitHub Secrets
#### Secret Name	Value
```
AZURE_CREDENTIALS	SP JSON
ACR_NAME	your ACR name
ACR_LOGIN_SERVER	e.g., acmeprodacr.azurecr.io
AKS_RG	resource group
AKS_NAME	aks cluster name
K8S_NAMESPACE	default
```
### 4.3 CI Pipeline (ci.yml)

#### Runs on PR:
```
Pytest unit tests

Code linting
```
### 4.4 CD Pipeline (cd.yml)

#### Runs on merge to main:
```
Build images

Push to ACR

Create images.json artifact

Pull AKS context

Apply manifests

Run kubectl set image

Rollout checks

Smoke test through Gateway

```

## 5. Application Deployment (Kubernetes)
#### 5.1 Microservice Deployments

Each service has:
```
Deployment

Service

HPA

Environment variable for App Insights connection string

Resource requests (required for HPA)

Example (User Service):

env:
  - name: APPINSIGHTS_CONNECTION_STRING
    valueFrom:
      secretKeyRef:
        name: appinsights-secret
        key: CONN

```
<img width="1908" height="917" alt="Screenshot 2025-11-27 at 8 22 56 AM" src="https://github.com/user-attachments/assets/a222b7b5-1916-4347-bc16-69bbbf059bb1" />

#### 5.2 Ingress Controller (NGINX)
```
Routes:

/users → user-service

/orders → order-service

/ → gateway

```

## 6.Secrets Management
#### Option A — Key Vault (recommended)

Store App Insights connection string:
```
az keyvault secret set --vault-name <KV_NAME> \
  --name "AppInsights-Conn" \
  --value "<CONNECTION_STRING>"

```
Use Secrets Store CSI driver in AKS
(or use Kubernetes Secret for demonstration).

## 7. Monitoring & Logging
### 7.1 Application Insights (OTel Traces)

User & Order services are instrumented using OpenTelemetry Azure Monitor Exporter.
```
You can verify via:
Portal → Application Insights → Logs

KQL:

requests | take 20
traces | take 20
dependencies | take 20
exceptions | take 20
```
### 7.2 Container Insights (Cluster Metrics)

#### Automatically enabled via Terraform:
```
Node metrics

Pod metrics

Container logs

HPA scaling behavior

Run:

kubectl top nodes
kubectl top pods
kubectl get hpa
```

<img width="1920" height="935" alt="Screenshot 2025-11-27 at 8 28 27 AM" src="https://github.com/user-attachments/assets/d489d3e9-10d9-47f4-92db-fcf5ba06f4b3" />

<img width="1915" height="951" alt="Screenshot 2025-11-27 at 8 29 45 AM" src="https://github.com/user-attachments/assets/25e229f5-54b7-4c07-a61f-2bcbf25c435d" />

<img width="1912" height="952" alt="Screenshot 2025-11-27 at 8 29 53 AM" src="https://github.com/user-attachments/assets/ab6ae9ea-fb96-435c-a582-be4c313f634c" />

<img width="1918" height="909" alt="Screenshot 2025-11-27 at 8 40 09 AM" src="https://github.com/user-attachments/assets/b898107b-4d41-4c83-bf04-7a20b93a6597" />
<img width="1920" height="951" alt="Screenshot 2025-11-27 at 8 40 19 AM" src="https://github.com/user-attachments/assets/cd76577d-5735-44f2-8f99-768527070cb6" />

## 8. Testing
#### Unit Tests (pytest)

Located in each Python service folder.
Executed in CI pipeline.

Integration Tests (optional)

Basic smoke test executed during CD:

Check Gateway /health

Check microservice endpoints

## 9. RBAC & Security

GitHub Actions uses Service Principal with:

AcrPush (ACR)

Contributor (AKS RG only)

Secrets stored in KV or environment secrets

No secrets stored in repo

CI workflow has no access to secrets (PR-safe)

## 10. Cost Optimization

Node size: Standard_B2ms (cheap & stable for tests)

HPA ensures pods scale automatically

Optionally enable Cluster Autoscaler

Use Log Analytics retention policies

Use separate dev/test/prod envs via TF workspaces

## 11. Deliverables Checklist

✔ Architecture diagram (docs/architecture.jpeg)
✔ Terraform scripts (terraform/)
✔ Microservices source code (src/)
✔ Kubernetes manifests (k8s/)
✔ CI/CD pipelines (ci.yml, cd.yml)
✔ README file (this file)
✔ Monitoring screenshots:

App Insights: Requests, Live Metrics, Application Map

Container Insights: Nodes, Pods, HPA

kubectl get pods / kubectl top pods

## 12. Troubleshooting
Deployment fails: “deployment not found”

Ensure manifest applied:

kubectl apply -f k8s/

HPA shows <unknown>

Add CPU requests in deployments

Install metrics server

No telemetry in App Insights
kubectl exec -it <pod> -- printenv | grep APPINSIGHTS


Check instrumentation code.

ACR login errors

Ensure:

az acr login -n <ACR_NAME>

## 13. Cleanup

Destroy resources:
```
cd terraform
terraform destroy -var-file="envs/prod.tfvars" -auto-approve

```
Delete GitHub SP:
```
az ad sp delete --id <APP_ID>
```
