# Todo App on AWS Fargate + RDS

A full-stack Todo application deployed serverlessly on **AWS ECS Fargate** with a managed **PostgreSQL** database on **RDS**.  
Frontend and backend are containerized, served via separate **Application Load Balancers (ALBs)**, and connected to a private RDS instance.

This project was built as a learning exercise to demonstrate:
- Infrastructure as Code with Terraform
- ECS Fargate for container orchestration
- RDS for managed PostgreSQL
- VPC with public/private subnets, NAT Gateway
- ECR for container image registry
- Load balancing with public ALBs
- Basic security groups and IAM roles

## Architecture Overview
Internet
↓
[Frontend ALB (public, port 80)] ── forwards to ── Frontend Fargate Service (port 80)
↓ (API calls from browser)
[Backend ALB (public, port 80)] ── forwards to ── Backend Fargate Service (port 8000)
↓ (internal VPC traffic)
[RDS PostgreSQL (private subnets)] ← connected via env vars (endpoint, user, pass)
text- **Frontend**: Serves static files (React/Vite/whatever SPA), makes API calls to backend ALB
- **Backend**: REST API (likely FastAPI/Flask/Node), connects to RDS
- **Database**: Amazon RDS PostgreSQL (private, db.t3.micro, free-tier eligible)
- **Networking**: VPC with public/private subnets, single NAT Gateway, DNS support
- **No EC2 instances** — fully serverless

## Features Implemented

- Terraform module for VPC (terraform-aws-modules/vpc/aws)
- Two public ALBs: one for frontend (port 80), one for backend (port 80 → 8000)
- ECS Fargate services for frontend and backend
- ECR repositories (mutable tags for easy :latest pushes)
- RDS PostgreSQL via terraform-aws-modules/rds/aws
- CloudWatch Logs for container logging
- Security groups allowing ALB → ECS and ECS → RDS
- Environment variables passed to backend for DB connection
- Frontend configured with `API_URL` pointing to backend ALB DNS name

## Prerequisites

- AWS account (with permissions for VPC, ECS, ECR, RDS, ALB, IAM)
- Terraform ≥ 1.5
- AWS CLI configured (`aws configure`)
- Docker installed (for building/pushing images)
- Git

## Folder Structure
.
├── terraform/
│   ├── main.tf          ← this file (full infra)
│   ├── provider.tf      ← AWS provider config
│   ├── variables.tf     ← all variables & defaults
│   ├── outputs.tf       ← useful outputs (ALB DNS names, etc.)
│   └── ...
├── todo_app-main/       ← your app source code (backend + frontend)
│   ├── backend/         ← Dockerfile, code
│   └── frontend/        ← Dockerfile, code
└── README.md
text## How to Deploy

1. **Clone the repo**

Initialize TerraformBashterraform init
Review the planBashterraform plan
Apply (create infrastructure)Bashterraform apply→ Type yes. Takes ~10–15 minutes (RDS is the slowest part).
Build & push Docker images
Go to your app folder: cd ../todo_app-main
Build backend: docker build -t todo-backend:latest ./backend (adjust path)
Build frontend: docker build -t todo-frontend:latest ./frontend
Authenticate to ECR:Bash
$password = aws ecr get-login-password --region us-east-1
 | docker login --username AWS --password $password acc_id.dkr.ecr.us-east-1.amazonaws.com/todo-app-frontend
Tag & push:Bashdocker tag todo-backend:latest <backend-ecr-repo-url>:latest
docker push <backend-ecr-repo-url>:latest
docker tag todo-frontend:latest <frontend-ecr-repo-url>:latest
docker push <frontend-ecr-repo-url>:latest

Update ECS services
Back in terraform folder: terraform apply again (forces new task revisions to pull :latest images)

Access the app
Run terraform output → look for frontend ALB DNS name
Open in browser: http://<frontend-alb-dns-name>
Register / login / add todos → should work end-to-end


Useful Outputs (add to outputs.tf if missing)
terraformoutput "frontend_url" {
  value       = "http://${aws_lb.frontend.dns_name}"
  description = "Public URL of the Todo frontend"
}

output "backend_alb_dns" {
  value       = aws_lb.backend.dns_name
  description = "DNS name of the backend API load balancer"
}

output "rds_endpoint" {
  value       = module.rds_postgres.db_instance_endpoint
  description = "RDS PostgreSQL endpoint"
}
Cleanup (important – to avoid costs!)
Bashterraform destroy
# Type yes — destroys everything including RDS and ALBs