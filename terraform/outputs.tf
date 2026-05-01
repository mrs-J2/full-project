output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "ecr_backend_repository_url" {
  value       = aws_ecr_repository.backend.repository_url
  description = "ECR repo URL for backend (push images here)"
}

output "ecr_frontend_repository_url" {
  value       = aws_ecr_repository.frontend.repository_url
  description = "ECR repo URL for frontend"

}
output "frontend_alb_dns" {
  value = aws_lb.frontend.dns_name
}
output "backend_alb_dns" {
  value = aws_lb.backend.dns_name
}
output "rds_endpoint" {
  description = "The connection endpoint"
  value       = module.rds_postgres.db_instance_endpoint
}
output "rds_address" {
  value = module.rds_postgres.db_instance_address
}
output "ecs_cluster_name" {
  value = aws_ecs_cluster.main.name
}

output "ecs_task_execution_role_arn" {
  value = aws_iam_role.ecs_task_execution_role.arn
}


/*ecr_backend_repository_url = "211125769956.dkr.ecr.us-east-1.amazonaws.com/todo-app-backend"
ecr_frontend_repository_url = "211125769956.dkr.ecr.us-east-1.amazonaws.com/todo-app-frontend"*/