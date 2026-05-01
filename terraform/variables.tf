variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"   
}

variable "vpc_name" {
  type    = string
  default = "todo-vpc"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "vpc_azs" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]   
}

variable "public_subnets_cidrs" {
  type    = list(string)
  default = ["10.0.10.0/24", "10.0.11.0/24"]
}

variable "private_subnets_cidrs" {
  type    = list(string)
  default = ["10.0.20.0/24", "10.0.21.0/24"]
}

variable "enable_dns_hostnames" { default = true }
variable "enable_dns_support"   { default = true }

variable "project_name" {
  type    = string
  default = "todo-app"
}

variable "environment" {
  type    = string
  default = "dev"   
}
# ──────────────────────────────────────────
# Environment-specific specs
# ──────────────────────────────────────────

variable "backend_cpu" {
  description = "ECS backend task CPU units"
  type        = number
  default     = 512
}


variable "backend_memory" {
  description = "ECS backend task memory (MB)"
  type        = number
  default     = 1024
}

variable "backend_desired_count" {
  description = "Number of backend ECS tasks"
  type        = number
  default     = 1
}

variable "frontend_cpu" {
  description = "ECS frontend task CPU units"
  type        = number
  default     = 256
}

variable "frontend_memory" {
  description = "ECS frontend task memory (MB)"
  type        = number
  default     = 512
}

variable "frontend_desired_count" {
  description = "Number of frontend ECS tasks"
  type        = number
  default     = 1
}

variable "rds_instance_class" {
  description = "RDS instance type"
  type        = string
  default     = "db.t3.micro"
}

variable "rds_allocated_storage" {
  description = "RDS allocated storage in GB"
  type        = number
  default     = 20
}

variable "rds_multi_az" {
  description = "Enable RDS Multi-AZ"
  type        = bool
  default     = false
}

variable "rds_backup_retention_period" {
  description = "RDS backup retention in days"
  type        = number
  default     = 7
}

variable "db_password_ssm_value" {
  description = "The actual DB password stored in SSM"
  type        = string
  sensitive   = true
}