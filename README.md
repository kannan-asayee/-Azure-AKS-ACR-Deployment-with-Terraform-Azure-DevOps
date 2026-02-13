🚀 Azure AKS + ACR Deployment with Terraform & Azure DevOps
Complete CI/CD Pipeline for Containerized Applications on Azure
📋 Project Overview
This project demonstrates a production-ready CI/CD pipeline that provisions Azure Kubernetes Service (AKS) and Azure Container Registry (ACR) using Terraform, then deploys a containerized Hello World application - all with a single click in Azure DevOps.

✨ Key Features
✅ Infrastructure as Code - 100% Terraform configuration

✅ Zero-Touch Deployment - One-click provisioning of ACR + AKS

✅ Automated Container Build - Docker image built and pushed to ACR

✅ Kubernetes Deployment - Hello World app deployed to AKS with LoadBalancer

✅ Workload Identity Federation - No secrets, no service principal passwords

✅ Cost Optimized - Standard tier AKS, can be stopped when not in use

✅ Self-Hosted Agent Ready - Configured for Azure DevOps self-hosted agents

🏗️ Architecture
text
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│   Azure DevOps  │────▶│    Terraform    │────▶│      Azure      │
│    Pipeline     │     │   Provisioning  │     │   Resources     │
└─────────────────┘     └─────────────────┘     └─────────────────┘
         │                       │                       │
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐     ┌─────────────────┐     ┌─────────────────┐
│  Stage 1: Infra │     │  • Resource Grp │     │      ACR        │
│  Deploy ACR+AKS │────▶│  • ACR Registry │────▶│   kannaalabacr  │
└─────────────────┘     │  • Log Analytics│     └─────────────────┘
         │              │  • AKS Cluster  │              │
         │              └─────────────────┘              │
         ▼                       │                       │
┌─────────────────┐              ▼                       ▼
│  Stage 2: App   │     ┌─────────────────┐     ┌─────────────────┐
│  Deploy Hello   │────▶│   Docker Build  │────▶│   AKS Cluster   │
│     App to AKS  │     │  & Push to ACR  │     │  Hello World!   │
└─────────────────┘     └─────────────────┘     └─────────────────┘
📁 Repository Structure
text
infralab-rev02/
├── terraform/
│   ├── main.tf              # ACR + AKS resource definitions
│   ├── variables.tf         # Input variables with defaults
│   ├── outputs.tf           # Output values for pipeline
│   └── providers.tf         # Provider and backend config
├── manifests/
│   ├── deployment.yaml      # Kubernetes deployment
│   └── service.yaml         # LoadBalancer service
├── Dockerfile               # Multi-stage container build
├── index.html              # Hello World web content
├── azure-pipelines.yml     # Complete two-stage pipeline
└── README.md              # You are here!
⚙️ Prerequisites
🔧 Azure Subscription
Active Azure subscription with Contributor access

Ability to create Service Principals

🖥️ Self-Hosted Agent Requirements
bash
# Required tools (pre-installed on agent)
terraform >= 1.6.0
docker >= 24.0
kubectl >= 1.28
azure-cli >= 2.50
git >= 2.40
🔑 Azure DevOps Setup
Service Connection (Workload Identity Federation)

Name: terraform-azure-wif

Scope: Subscription-level Contributor

Variable Group - Terraform-ACR-AKS

yaml
ACR_NAME: kannaalabacr
AKS_CLUSTER_NAME: aks-dev-cluster
RESOURCE_GROUP_NAME: rg-aks-dev
LOCATION: eastus
ENVIRONMENT: dev
VM_SIZE: Standard_D2s_v3
NODE_COUNT: 2
KUBERNETES_VERSION: 1.32.10
Terraform State Storage (One-time setup)

bash
az group create --name rg-terraform-state --location eastus
az storage account create --name terraformazlabstate01 --resource-group rg-terraform-state --sku Standard_LRS
az storage container create --name terraform-state --account-name terraformazlabstate01
🚀 Deployment Instructions
Step 1: Clone Repository
bash
git clone https://dev.azure.com/yourorg/infralab-rev02
cd infralab-rev02
git checkout rev02br
Step 2: Configure Azure DevOps
Create Variable Group
Navigate to Pipelines → Library

Click "+ Variable Group"

Name: Terraform-ACR-AKS

Add all variables from prerequisites

Click "Save"

Create Service Connection
Navigate to Project Settings → Service Connections

Click "New Service Connection" → Azure Resource Manager

Select "Workload Identity Federation (Automatic)"

Select your subscription

Name: terraform-azure-wif

Check "Grant access permission to all pipelines"

Click "Save"

Step 3: Grant Required Permissions
Run these commands ONCE on your self-hosted agent:

bash
# Get your service principal object ID from Azure DevOps
# (Found in Service Connection → Manage Service Principal)

# Assign Contributor role
az role assignment create \
  --assignee "YOUR-SERVICE-PRINCIPAL-OBJECT-ID" \
  --role "Contributor" \
  --scope "/subscriptions/YOUR-SUBSCRIPTION-ID"

# Assign User Access Administrator (for ACR pull role assignment)
az role assignment create \
  --assignee "YOUR-SERVICE-PRINCIPAL-OBJECT-ID" \
  --role "User Access Administrator" \
  --scope "/subscriptions/YOUR-SUBSCRIPTION-ID"

# Assign Storage Blob Data Contributor (for Terraform state)
az role assignment create \
  --assignee "YOUR-SERVICE-PRINCIPAL-OBJECT-ID" \
  --role "Storage Blob Data Contributor" \
  --scope "/subscriptions/YOUR-SUBSCRIPTION-ID/resourceGroups/rg-terraform-state/providers/Microsoft.Storage/storageAccounts/terraformazlabstate01"
Step 4: Run the Pipeline
Navigate to Pipelines in Azure DevOps

Click "New Pipeline" → Azure Repos Git

Select infralab-rev02 → branch rev02br

Choose "Existing Azure Pipelines YAML File" → /azure-pipelines.yml

Click "Run"

⏱️ Duration: ~10-12 minutes total

Stage 1 (Infrastructure): 5-8 minutes

Stage 2 (Application): 2-3 minutes

📊 What Happens Behind the Scenes
Stage 1: Infrastructure Deployment
Resource	Purpose	Configuration
Resource Group	Container for all resources	rg-aks-dev
ACR	Docker registry	Basic SKU, admin disabled
Log Analytics	AKS monitoring	PerGB2018 SKU
AKS Cluster	Kubernetes orchestrator	Standard tier, D2s_v3 nodes
Role Assignment	ACR pull access	AcrPull role for AKS kubelet
Stage 2: Application Deployment
Step	Action	Technology
1	Build Docker image	Docker + Nginx Alpine
2	Push to ACR	Azure CLI + Docker
3	Get AKS credentials	az aks get-credentials
4	Deploy to Kubernetes	kubectl apply
5	Expose via LoadBalancer	Kubernetes Service
6	Output public URL	Automatic IP retrieval
💰 Cost Optimization
Stop Cluster When Not in Use
bash
# Stop AKS (saves ~$140/month)
az aks stop --name aks-dev-cluster --resource-group rg-aks-dev

# Start when needed
az aks start --name aks-dev-cluster --resource-group rg-aks-dev
Monthly Cost Breakdown
Resource	Tier	Running Cost	Stopped Cost
AKS Control Plane	Standard	~$73/month	$0
Worker Nodes (2x D2s_v3)	Pay-as-you-go	~$66/month	$0
ACR	Basic	~$5/month	~$5/month
Storage	Managed disks	~$2/month	~$2/month
Public IP	Static	~$3/month	~$3/month
Total		~$149/month	~$10/month
💡 Pro Tip: Schedule automated start/stop using Azure Automation Account for dev environments.

🔧 Troubleshooting Guide
Common Issues & Solutions
1. VM Size Not Available
text
Error: The VM size of Standard_DS2_v2 is not allowed in your subscription
✅ Fix: Change to Standard_D2s_v3 in Variable Group

2. Role Assignment Failed
text
Error: AuthorizationFailed - does not have authorization to perform action
✅ Fix: Grant User Access Administrator role to service principal

3. ACR Login Empty
text
ERROR: argument --name/-n: expected one argument
✅ Fix: Use pipeline artifacts to pass variables between stages (implemented in YAML)

4. Terraform State 403
text
Error: Failed to get existing workspaces: listing blobs: unexpected status 403
✅ Fix:

bash
az role assignment create --assignee "OBJECT-ID" --role "Storage Blob Data Contributor" --scope "STORAGE-ACCOUNT-SCOPE"
5. Detached HEAD State
text
fatal: You are not currently on a branch.
✅ Fix:

bash
git checkout -b rev02br
git push -u origin rev02br
🎯 Key Learnings & Best Practices
✅ Terraform
Always set default values for variables

Use skip_provider_registration = true to avoid 403 errors

Store state remotely with access key or Azure AD auth

✅ Azure DevOps
Use Workload Identity Federation - no secrets management

Pass variables between stages using Pipeline Artifacts (not stage dependencies)

Add debug tasks when troubleshooting variable passing

✅ AKS
Check VM quota before deployment: az vm list-usage --location eastus

Use Standard tier for dev/test, Premium only for LTS

Stop clusters overnight to save 70%+ costs

✅ Security
Never enable admin on ACR

Use managed identities, not service principal secrets

Grant least-privilege RBAC roles

📈 Performance Metrics
Operation	Average Time
Terraform Init	10 seconds
ACR Creation	20 seconds
AKS Cluster Creation	4-6 minutes
Docker Build + Push	45 seconds
Kubernetes Deployment	30 seconds
LoadBalancer IP Provisioning	20-30 seconds
Total Pipeline	8-10 minutes
🔄 Extending the Project
Add Multiple Environments
hcl
# terraform/environments/
├── dev/
│   └── terraform.tfvars
├── staging/
│   └── terraform.tfvars
└── prod/
    └── terraform.tfvars
Implement Helm Charts
bash
# Replace manual manifests with Helm
helm create hello-app
helm upgrade --install hello-app ./hello-app
Add Ingress Controller
yaml
# Instead of LoadBalancer per service
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: hello-app-ingress
spec:
  ingressClassName: nginx
  rules:
  - host: hello.yourapp.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: hello-app-service
            port:
              number: 80
CI/CD Enhancements
Add Terraform plan approval gates

Implement unit tests for Docker image

Add security scanning (Trivy, Snyk)

Configure auto-scaling based on metrics

🏆 Achievements
✅ Infrastructure as Code - 100% Terraform
✅ Zero-Touch Deployment - One-click provisioning
✅ Containerization - Docker + ACR
✅ Orchestration - Kubernetes on AKS
✅ CI/CD - Azure DevOps pipelines
✅ Security - Workload Identity Federation
✅ Cost Optimization - Stop/start capability
✅ Documentation - Complete README

📚 References
Azure Kubernetes Service (AKS) Documentation

Azure Container Registry (ACR) Documentation

Terraform AzureRM Provider

Azure DevOps Pipeline Documentation

Workload Identity Federation

👨‍💻 Author
Kannan Annadurai - Cloud/DevOps Engineer

📝 License
This project is licensed under the MIT License - see the LICENSE file for details.

🙏 Acknowledgments
Azure DevOps Team for Workload Identity Federation
HashiCorp for Terraform
Kubernetes Community
Microsoft Learn Documentation
Happy Cloud Deployments! 🚀☁️
