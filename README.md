# Production-Style AWS Infrastructure + CI/CD

## 📌 Project Overview

This project implements a production-style AWS infrastructure and CI/CD deployment pipeline using **Terraform, Jenkins, Docker, Amazon ECR, Amazon ECS Fargate, Application Load Balancer, IAM, S3, and CloudWatch**.

The project automates the complete application deployment process:

```text
GitHub → Jenkins → Maven → Docker → Amazon ECR → ECS Fargate → ALB → Application
```

Terraform is used to provision the AWS infrastructure, while Jenkins automates application build, containerization, image publishing, and ECS deployment.

---

# 🏗️ Architecture

```text
                         ┌──────────────────┐
                         │      GitHub      │
                         │ Java Application │
                         └────────┬─────────┘
                                  │
                           GitHub Webhook
                                  │
                                  ▼
                         ┌──────────────────┐
                         │     Jenkins      │
                         │      EC2         │
                         └────────┬─────────┘
                                  │
                ┌─────────────────┼─────────────────┐
                │                 │                 │
                ▼                 ▼                 ▼
             Maven             Docker          AWS CLI/JQ
          Test / Package         Build              │
                │                 │                 │
                └─────────────────┼─────────────────┘
                                  │
                                  ▼
                         ┌──────────────────┐
                         │   Amazon ECR     │
                         │ Docker Registry  │
                         └────────┬─────────┘
                                  │
                                  ▼
                         ┌──────────────────┐
                         │  Amazon ECS      │
                         │    Fargate       │
                         └────────┬─────────┘
                                  │
                                  ▼
                         ┌──────────────────┐
                         │ Application Load │
                         │    Balancer      │
                         └────────┬─────────┘
                                  │
                                  ▼
                         ┌──────────────────┐
                         │   Application    │
                         └──────────────────┘
```

---

# ☁️ AWS Infrastructure

The AWS infrastructure is provisioned using Terraform.

### AWS Resources

* VPC
* Public Subnets
* Private Subnets
* Internet Gateway
* NAT Gateway
* Route Tables
* Security Groups
* Application Load Balancer
* Target Group
* Amazon ECR Repository
* Amazon ECS Cluster
* ECS Task Definition
* ECS Service
* ECS Fargate
* IAM Roles
* CloudWatch Log Group
* S3 Terraform Backend
* EBS Volume
* Jenkins EC2 Instance

---

# 🛠️ Tools & Technologies

| Technology                | Purpose                       |
| ------------------------- | ----------------------------- |
| AWS                       | Cloud infrastructure          |
| EC2                       | Jenkins server                |
| EBS                       | Persistent Jenkins storage    |
| Terraform                 | Infrastructure as Code        |
| Jenkins                   | CI/CD automation              |
| GitHub                    | Source code management        |
| GitHub Webhook            | Automatic pipeline trigger    |
| Java                      | Application                   |
| Maven                     | Build and testing             |
| Docker                    | Containerization              |
| Amazon ECR                | Docker image registry         |
| Amazon ECS Fargate        | Container deployment          |
| Application Load Balancer | Application access            |
| AWS CLI                   | AWS operations                |
| jq                        | JSON processing               |
| Linux                     | Jenkins server environment    |
| S3                        | Terraform remote state        |
| CloudWatch                | Application/container logging |

---

# 🚀 Implementation Steps

## 1. Launch EC2 Instance

An EC2 instance is launched to act as the Jenkins and CI/CD execution server.

The instance is configured with the required security group and access for administration and application deployment.

The EC2 instance is used to:

* Run Jenkins
* Execute Terraform
* Build the Java application
* Build Docker images
* Authenticate with AWS
* Push images to Amazon ECR
* Deploy the application to ECS

---

## 2. Install Required Tools on EC2

The required DevOps tools are installed on the Jenkins EC2 instance.

### Tools Installed

```text
Java
Jenkins
Git
Maven
Docker
AWS CLI
Terraform
jq
```

Example verification:

```bash
java -version
jenkins --version
git --version
mvn -version
docker --version
aws --version
terraform --version
jq --version
```

The EC2 instance therefore acts as the CI/CD execution environment.

---

# 🔐 3. Configure AWS CLI

AWS CLI is configured on the Jenkins EC2 instance to allow Jenkins and Terraform to interact with AWS.

```bash
aws configure
```

The required AWS configuration includes:

```text
AWS Access Key ID
AWS Secret Access Key
Default region
Output format
```

Example:

```bash
aws sts get-caller-identity
```

This command is used to verify that the EC2 environment can successfully authenticate with AWS.

> For production environments, IAM roles, Jenkins credentials, AWS Secrets Manager, or other secure credential-management mechanisms should be preferred over storing long-lived access keys directly on the server.

---

# 🏗️ 4. Terraform Infrastructure Provisioning

After configuring the EC2 environment and AWS authentication, Terraform is used to provision the AWS infrastructure.

The Terraform configuration creates:

* VPC
* Public and private subnets
* Internet Gateway
* NAT Gateway
* Route tables
* Security groups
* Application Load Balancer
* Target Group
* ECR repository
* ECS cluster
* ECS task definition
* ECS service
* IAM roles
* CloudWatch Log Group
* S3 backend

### Initialize Terraform

```bash
cd JavaApplication/terraform
terraform init
```

### Validate Configuration

```bash
terraform validate
```

### Create Terraform Plan

```bash
terraform plan
```

### Apply Infrastructure

```bash
terraform apply
```

Terraform provisions the required AWS infrastructure automatically.

---

# 🗄️ 5. Terraform Remote State with S3

An S3 bucket is used as the Terraform remote backend.

The backend provides centralized storage for Terraform state.

Example:

```text
Terraform
    ↓
S3 Backend
    ↓
terraform.tfstate
```

This allows Terraform state to persist independently of the local EC2 environment.

---

# 💾 6. EBS Storage

An EBS volume is created and attached to the Jenkins EC2 instance.

The EBS volume provides persistent block storage for Jenkins-related data and server requirements.

```text
Jenkins EC2
     │
     └── EBS Volume
```

---

# 📁 7. GitHub Repository Setup

The application source code and DevOps configuration are maintained in GitHub.

The repository contains:

```text
Java Application
Dockerfile
Jenkinsfile
Terraform
ECS Task Definition
README
```

Suggested repository structure:

```text
JavaApplication/
│
├── terraform/
│   ├── backend.tf
│   ├── provider.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── vpc/
│   ├── alb/
│   ├── ecr/
│   ├── ecs/
│   ├── iam/
│   └── cloudwatch/
│
├── src/
│
├── Dockerfile
├── pom.xml
├── Jenkinsfile
├── taskdef.json
└── README.md
```

---

# ⚙️ 8. Jenkins Configuration

Jenkins is configured on the EC2 instance.

The Jenkins pipeline is configured using:

```text
Pipeline Definition:
Pipeline script from SCM

SCM:
Git

Repository:
GitHub Repository
```

Jenkins retrieves the `Jenkinsfile` directly from the GitHub repository.

---

# 🔑 9. IAM Configuration

IAM permissions are configured for AWS operations performed by the project.

### Infrastructure Provisioning

The AWS identity used by Terraform has permissions required to create and manage the infrastructure.

### Jenkins AWS Operations

An IAM role is attached to the Jenkins EC2 instance with permissions required for CI/CD operations such as:

* ECR authentication
* ECR image push
* ECS task-definition registration
* ECS service deployment
* CloudWatch-related operations

This allows Jenkins running on EC2 to interact with AWS resources.

---

# 🔔 10. GitHub Webhook Setup

GitHub is configured to automatically trigger the Jenkins pipeline whenever code is pushed to the repository.

The flow is:

```text
Developer
    │
    │ git push
    ▼
 GitHub
    │
    │ Webhook
    ▼
 Jenkins
    │
    ▼
 Pipeline Triggered
```

The Jenkins **Generic Webhook Trigger** plugin is configured to receive the GitHub webhook request.

This removes the need to manually start the Jenkins pipeline after every code change.

---

# 🔄 11. CI/CD Pipeline

The Jenkins pipeline automates the application deployment process.

### Pipeline Flow

```text
GitHub Push
     ↓
GitHub Webhook
     ↓
Jenkins
     ↓
Checkout SCM
     ↓
Maven Test
     ↓
Maven Package
     ↓
Docker Build
     ↓
ECR Login
     ↓
Push Image to ECR
     ↓
Prepare ECS Task Definition
     ↓
Register ECS Task Definition
     ↓
Deploy to ECS
     ↓
Wait for ECS Deployment
     ↓
Deployment Verification
     ↓
Application Available through ALB
```

---

# 🧪 12. Jenkins Pipeline Stages

## Stage 1: Checkout SCM

Jenkins checks out the latest source code from GitHub.

---

## Stage 2: Maven Test

Maven executes the application's test cases.

```bash
mvn test
```

---

## Stage 3: Maven Package

The Java application is packaged using Maven.

```bash
mvn package
```

---

## Stage 4: Docker Build

A Docker image is created from the Java application.

```bash
docker build -t <image-name> .
```

---

## Stage 5: ECR Login

Jenkins authenticates Docker with Amazon ECR.

```bash
aws ecr get-login-password --region <region> | \
docker login --username AWS --password-stdin <ecr-repository>
```

---

## Stage 6: Push Image to ECR

The Docker image is tagged and pushed to Amazon ECR.

```bash
docker push <ecr-image>
```

---

## Stage 7: Prepare ECS Task Definition

The pipeline updates the ECS task definition with the newly created ECR image.

---

## Stage 8: Register ECS Task Definition

The updated task definition is registered with Amazon ECS.

---

## Stage 9: Deploy to ECS

The ECS service is updated to use the new task definition.

---

## Stage 10: Wait for ECS Deployment

Jenkins waits for the ECS service to reach a stable deployment state.

---

## Stage 11: Deployment Verification

The pipeline verifies that the deployment completed successfully.

---

## Stage 12: Post Actions

Temporary files and generated task-definition files are cleaned up after deployment.

---

# 📊 13. Successful Pipeline

A successful Jenkins execution completes all deployment stages:

```text
✓ Checkout SCM
✓ Maven Test
✓ Maven Package
✓ Docker Build
✓ ECR Login
✓ Push Image to ECR
✓ Prepare ECS Task Definition
✓ Register ECS Task Definition
✓ Deploy to ECS
✓ Wait for ECS Deployment
✓ Deployment Verification
✓ Post Actions
```

Example:

```text
==================== DEPLOYMENT SUCCESSFUL ====================

Docker Image: <ECR image>
ECS Cluster: ecs-devops-cluster
ECS Service: ecs-devops-service
```

---

# 🌐 14. Application Deployment

After ECS successfully deploys the container, the application is accessed through the Application Load Balancer.

```text
Internet
   ↓
Application Load Balancer
   ↓
ECS Fargate
   ↓
Docker Container
   ↓
Java Application
```

The ALB provides the entry point for accessing the deployed application.

---

# 🔐 15. Security Considerations

The project demonstrates AWS IAM and network-level security controls.

Key practices include:

* IAM-based access control
* EC2 IAM role for Jenkins AWS operations
* Security groups controlling network access
* Private subnets for application infrastructure
* IAM roles for AWS services
* No AWS credentials inside application source code
* Terraform state stored remotely in S3
* Controlled access between ALB and ECS resources

For production environments, IAM policies should follow the **principle of least privilege** and credentials should be managed using secure credential-management mechanisms.

---

# 📸 16. Project Evidence

Since AWS resources may be destroyed after testing to control costs, deployment evidence is maintained in the GitHub repository.

Recommended screenshots:

1. EC2 instance
2. Installed tools/version verification
3. AWS CLI authentication
4. Terraform plan
5. Terraform apply
6. VPC and subnet configuration
7. ECR repository with Docker image
8. ECS cluster
9. ECS service
10. Application Load Balancer
11. Jenkins pipeline stages
12. Successful Jenkins deployment
13. GitHub webhook configuration
14. Successful ECS task
15. Application accessed through ALB

Suggested evidence folder:

```text
evidence/
├── 01-ec2.png
├── 02-tools-installed.png
├── 03-aws-configure.png
├── 04-terraform-plan.png
├── 05-terraform-apply.png
├── 06-vpc.png
├── 07-ecr.png
├── 08-ecs-cluster.png
├── 09-ecs-service.png
├── 10-alb.png
├── 11-jenkins-pipeline.png
├── 12-deployment-success.png
├── 13-github-webhook.png
└── 14-application.png
```

---

# 🎯 Key DevOps Concepts Demonstrated

This project demonstrates hands-on experience with:

* Infrastructure as Code
* Terraform
* Terraform modules
* Terraform remote state
* AWS networking
* VPC architecture
* Public/private subnet design
* NAT Gateway
* IAM
* EC2
* EBS
* Docker
* Amazon ECR
* Amazon ECS Fargate
* Application Load Balancer
* CloudWatch
* Maven
* Jenkins
* Jenkins Pipeline
* GitHub SCM
* GitHub Webhooks
* CI/CD automation
* AWS CLI
* Linux administration

---

# 💡 Project Highlights

### Infrastructure Automation

AWS infrastructure is provisioned using Terraform instead of manually creating resources through the AWS Console.

### Automated CI/CD

A GitHub push automatically triggers Jenkins through a webhook.

### Containerized Deployment

The Java application is packaged into a Docker image and published to Amazon ECR.

### Fargate Deployment

The application is deployed using Amazon ECS Fargate without managing ECS worker EC2 instances.

### Production-Style Networking

The architecture uses VPC, public/private subnets, NAT Gateway, security groups, and an Application Load Balancer.

### End-to-End Automation

The project combines:

```text
Infrastructure as Code
        +
CI/CD
        +
Containerization
        +
AWS Cloud Deployment
```

---

# 📝 Resume Project Description

**Production-Style AWS Infrastructure & CI/CD**

Designed and implemented an end-to-end AWS deployment platform using **Terraform, Jenkins, Docker, Amazon ECR, ECS Fargate, Application Load Balancer, IAM, S3, and CloudWatch**. Automated infrastructure provisioning and Java application deployment through a Jenkins CI/CD pipeline triggered by GitHub webhooks. Implemented Maven testing/build, Docker image creation, ECR publishing, ECS task-definition registration, and automated ECS service deployment.

---

# 🏁 Final Result

The complete deployment workflow is automated:

```text
Developer
    │
    │ git push
    ▼
 GitHub
    │
    │ Webhook
    ▼
 Jenkins EC2
    │
    ├── Maven Test
    ├── Maven Package
    ├── Docker Build
    ├── ECR Login
    └── Push Image
           │
           ▼
       Amazon ECR
           │
           ▼
       Amazon ECS
         Fargate
           │
           ▼
 Application Load Balancer
           │
           ▼
       Application
```

**Status: ✅ End-to-End CI/CD Pipeline Successfully Implemented**
