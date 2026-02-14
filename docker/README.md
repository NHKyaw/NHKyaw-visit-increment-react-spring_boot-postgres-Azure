# Visit Increment – Full Stack CI/CD Project

A full-stack application using **React**, **Spring Boot**, and **PostgreSQL**, with a complete **GitHub Actions CI/CD pipeline**, **Docker**, **Terraform**, and **AWS EC2 deployment**.

This project demonstrates a real-world DevOps workflow from code → test → build → deploy.

---

## 📁 Repository Structure

├── .github/workflows/
│ ├── mainpipeline.yaml # Orchestrates full pipeline
│ ├── test.yaml # Test stage
│ ├── build.yaml # Docker build & push
│ └── deploy.yaml # Terraform + EC2 deployment
├── backend/ # Spring Boot backend
├── frontend/ # React frontend
├── docker/ # Docker Compose & deploy scripts
├── terraform/ # Infrastructure as Code
└── README.md


---

## 🔁 Git Workflow & Branch Strategy

### Branches

| Branch | Purpose | Docker Image Tag |
|------|--------|------------------|
| `main` / `master` | Production | `prod` |
| `dev` | Development | `dev` |
| `uat` | UAT testing | `uat` |
| other branches | Feature / experiment | branch name |

Docker image tags are derived automatically from the branch name.

---

## 🚦 CI/CD Pipeline Overview


### Pipeline Entry Point
.github/workflows/mainpipeline.yaml


This workflow calls reusable workflows for **test**, **build**, and **deploy** stages.

---

## 🧪 Test Stage (`test.yaml`)

Runs first. If tests fail, the pipeline stops.

### What it does
- Starts PostgreSQL service container
- Runs backend (Spring Boot) tests
- Runs frontend (React) tests

### Tools & Versions
- Java 21 (Temurin)
- Node.js 20
- PostgreSQL 15
- Maven & npm caching enabled

---

## 🏗 Build Stage (`build.yaml`)

Triggered only if tests pass.

### Backend Image

### Docker Tag Logic
- `main` / `master` → `prod`
- Other branches → branch name

Images are pushed to **Docker Hub**.

---

## 🚀 Deploy Stage (`deploy.yaml`)

Deployment runs **only** for these branches:
dev, uat, main


### Deployment Flow

1. Map branch → environment (`ENV`)
2. Configure AWS credentials
3. Run Terraform:
   - `terraform init`
   - `terraform apply`
   - *(temporary)* `terraform destroy`
4. Retrieve EC2 public IP
5. Copy Docker files to EC2
6. SSH into EC2
7. Run `deploy.sh` to:
   - Pull Docker images
   - Start containers with Docker Compose

Deployment target: **AWS EC2**

---

## 🔐 Required GitHub Secrets

You must configure the following **Repository Secrets**:

### Docker Hub
DOCKER_USERNAME
DOCKER_PASSWORD

### AWS
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
EC2_SSH_KEY

## 🧱 Reusable Workflows

| Workflow | Purpose |
|--------|--------|
| `test.yaml` | Run backend & frontend tests |
| `build.yaml` | Build & push Docker images |
| `deploy.yaml` | Provision infra & deploy app |
| `mainpipeline.yaml` | Full pipeline orchestration |

Docker is used for:
- Backend container
- Frontend container
- PostgreSQL container
- Deployment via Docker Compose on EC2

Terraform provisions cloud infrastructure:
- EC2
- Networking components
- Outputs EC2 public IP for deployment

Terraform state is environment-specific. (Store in Amazon S3)

- Clean Test → Build → Deploy separation
- Branch-based environment control
- Docker image versioning per environment
- Infrastructure as Code with Terraform
- SSH-based EC2 deployment
- Reusable GitHub Actions workflows


