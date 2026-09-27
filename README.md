# Production-Style AWS Infrastructure + CI/CD

## 📌 Project Overview

This project implements a production-style AWS infrastructure and CI/CD deployment pipeline using **Terraform, Jenkins, Docker, Amazon ECR, Amazon ECS Fargate, and AWS Application Load Balancer**.

The objective was to automate the complete application deployment process:

**GitHub → Jenkins → Maven → Docker → Amazon ECR → Amazon ECS Fargate → Application Load Balancer → Application**

Infrastructure is provisioned using Terraform, while Jenkins automates the application build, container image creation, image push, ECS task definition registration, and deployment.

---

## 🏗️ Architecture

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
                 ┌────────────────┼─────────────────┐
                 │                │                 │
                 ▼                ▼                 ▼
              Maven            Docker          AWS CLI/JQ
            Test/Package       Build              │
                 │                │                 │
                 └────────────────┼─────────────────┘
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

The infrastructure was created using Terraform.

### AWS resources used

- VPC
- Public Subnets
- Private Subnets
- Internet Gateway
- NAT Gateway
- Route Tables
- Security Groups
- Application Load Balancer
- Target Group
- Amazon ECR Repository
- Amazon ECS Cluster
- ECS Task Definition
- ECS Service
- ECS Fargate
- IAM Roles
- CloudWatch Log Group
- S3 Terraform Backend
- EBS Volume

---

# 🛠️ Tools & Technologies

| Technology | Purpose |
|---|---|
| AWS | Cloud infrastructure |
| Terraform | Infrastructure as Code |
| Jenkins | CI/CD automation |
| GitHub | Source code management |
| GitHub Webhook | Automatic pipeline trigger |
| Java | Application/runtime |
| Maven | Build and test |
| Docker | Containerization |
| Amazon ECR | Docker image registry |
| Amazon ECS Fargate | Container deployment |
| Application Load Balancer | Application access/load balancing |
| AWS CLI | AWS resource operations |
| jq | JSON processing in pipeline |
| Linux | Jenkins server/automation environment |
| S3 | Terraform remote state |

---

# 🚀 Implementation Steps

## 1. Terraform S3 Bootstrap

Created Terraform configuration for the S3 backend used to store Terraform remote state.

The S3 backend provides centralized and persistent Terraform state storage.

---

## 2. Created AWS Infrastructure with Terraform

Created Terraform code for the required AWS infrastructure, including:

- VPC
- Public and private subnets
- NAT Gateway
- Route tables
- Security groups
- Application Load Balancer
- ECR
- ECS cluster
- ECS task definition
- ECS service
- IAM roles
- CloudWatch
- S3 backend

Terraform was used to provision the infrastructure instead of creating resources manually through the AWS Console.

---

## 3. Jenkins EC2 Setup

Launched an EC2 instance to act as the Jenkins server.

Installed the required tools:

```text
Java
Jenkins
Git
AWS CLI
Terraform
Docker
jq
Maven
```

The EC2 instance acts as the CI/CD execution environment.

---

## 4. Git Repository Setup

The application source code and infrastructure/pipeline files were maintained in GitHub.

The Jenkins pipeline was configured using:

```text
Pipeline Definition:
Pipeline script from SCM

SCM:
Git

Repository:
GitHub repository
```

---

## 5. IAM Configuration

Created an IAM user with the required permissions for provisioning and managing the AWS resources used by the project.

AWS credentials were configured on the Jenkins EC2 environment so that AWS CLI commands used by the pipeline could authenticate with AWS.

In addition, an IAM role containing the required **Amazon ECR/ECS permissions** was attached to the Jenkins EC2 instance.

This allowed Jenkins to perform operations such as:

- ECR authentication
- ECR image operations
- ECS task definition registration
- ECS deployment operations

The project therefore demonstrates both:

- IAM user-based AWS authentication
- EC2 IAM role-based permissions

---

## 6. EBS Storage

Created an EBS volume and attached it to the Jenkins EC2 instance.

The EBS storage was used for Jenkins-related storage requirements.

This provides persistent block storage for the Jenkins server beyond the EC2 instance's local configuration.

---

# 🔄 CI/CD Pipeline

The Jenkins pipeline automates the complete deployment process.

### Pipeline flow

```text
GitHub Push
     ↓
Checkout SCM
     ↓
Checkout
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
Post Actions
```

---

# 🧪 Pipeline Stages

### 1. Checkout SCM

Jenkins checks out the latest source code from GitHub.

### 2. Checkout

The application source code is prepared for the build process.

### 3. Maven Test

Maven executes the application's test cases.

```bash
mvn test
```

### 4. Maven Package

The application is packaged using Maven.

```bash
mvn package
```

### 5. Docker Build

A Docker image is created from the application.

Example:

```bash
docker build -t <image-name> .
```

### 6. ECR Login

Jenkins authenticates Docker with Amazon ECR.

```bash
aws ecr get-login-password --region <region> | \
docker login --username AWS --password-stdin <ecr-repository>
```

### 7. Push Image to ECR

The Docker image is tagged and pushed to Amazon ECR.

```bash
docker push <ecr-image>
```

### 8. Prepare ECS Task Definition

The pipeline prepares the ECS task definition using the newly created ECR image.

### 9. Register ECS Task Definition

The updated task definition is registered with ECS.

### 10. Deploy to ECS

The ECS service is updated to use the new task definition.

### 11. Wait for ECS Deployment

Jenkins waits for ECS to complete the deployment and reach a stable state.

### 12. Deployment Verification

The pipeline verifies that the deployment completed successfully.

### 13. Post Actions

Temporary task-definition files and other generated files are cleaned up.

---

# 🔔 GitHub Webhook Integration

Configured the Jenkins **Generic Webhook Trigger** plugin.

GitHub was configured to send a webhook whenever changes are pushed to the repository.

```text
Developer Push
      ↓
GitHub
      ↓
Webhook
      ↓
Jenkins
      ↓
Pipeline Triggered
```

This removes the need to manually start the Jenkins pipeline after every GitHub push.

---

# 📊 Successful Pipeline

The Jenkins pipeline successfully completed all stages.

The successful execution included:

```text
✓ Checkout SCM
✓ Checkout
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

Example successful deployment output:

```text
==================== DEPLOYMENT SUCCESSFUL ====================
Docker Image: <ECR image>
ECS Cluster: ecs-devops-cluster
ECS Service: ecs-devops-service
```

---

# 🔐 Security Considerations

The project uses AWS IAM to control access to AWS resources.

Key practices demonstrated:

- IAM user for infrastructure provisioning
- EC2 IAM role for Jenkins AWS operations
- Separate permissions for ECR/ECS operations
- Security groups controlling network access
- Private subnets for application infrastructure
- IAM roles for AWS services
- No hard-coded AWS access keys inside the application code
- Terraform remote state stored in S3

> For a production environment, IAM policies should follow least-privilege principles and credentials should preferably be supplied through secure credential-management mechanisms rather than stored directly on the Jenkins host.

---

# 📁 Suggested Repository Structure

```text
project/
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
│
├── pom.xml
│
├── Jenkinsfile
│
├── taskdef.json
│
└── README.md
```

---

# 🎯 Key DevOps Concepts Demonstrated

This project demonstrates hands-on experience with:

- Infrastructure as Code
- Terraform modules
- Terraform remote state
- AWS networking
- VPC architecture
- Public/private subnet design
- NAT Gateway
- IAM
- EC2
- EBS
- Docker
- Container image management
- Amazon ECR
- Amazon ECS Fargate
- Application Load Balancer
- CloudWatch
- Maven
- Jenkins
- Jenkins Pipeline
- GitHub SCM
- GitHub Webhooks
- CI/CD automation
- Automated ECS deployments
- AWS CLI
- Linux administration

---

# 💡 Project Highlights

### Infrastructure Automation

AWS infrastructure is provisioned using Terraform rather than manually creating resources.

### Automated CI/CD

A GitHub push automatically triggers Jenkins through a webhook.

### Containerized Deployment

The Java application is packaged into a Docker image and stored in Amazon ECR.

### Serverless Container Deployment

The application is deployed using ECS Fargate without managing ECS worker EC2 instances.

### Production-Style Networking

The architecture uses VPC, public/private subnets, NAT Gateway, security groups, and an Application Load Balancer.

### Infrastructure + Application Deployment

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

# 📸 Project Evidence

Recommended screenshots to include in the repository:

1. Terraform plan
2. Terraform apply
3. AWS VPC/subnet architecture
4. ECR repository with pushed image
5. ECS cluster
6. ECS service
7. ALB
8. Jenkins pipeline stages
9. Successful Jenkins deployment
10. GitHub webhook configuration
11. Successful ECS task
12. Application accessed through ALB

---

# 🏁 Final Result

The complete deployment process is automated:

```text
Developer
   │
   │ git push
   ▼
GitHub
   │
   │ webhook
   ▼
Jenkins
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
