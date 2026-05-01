module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.6"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs             = var.vpc_azs
  private_subnets = var.private_subnets_cidrs
  public_subnets  = var.public_subnets_cidrs

  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnet_suffix  = "pub"
  private_subnet_suffix = "prv"

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }

  igw_tags = {
    Name = "${var.vpc_name}-igw"
  }

  public_route_table_tags = {
    Name = "${var.vpc_name}-public-rt"
  }

  private_route_table_tags = {
    Name = "${var.vpc_name}-private-rt"
  }
}



//ALB
resource "aws_lb" "frontend" {
  name               = "${var.project_name}-frontend-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = module.vpc.public_subnets
}

resource "aws_lb_listener" "frontend_http" {
  load_balancer_arn = aws_lb.frontend.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
}
resource "aws_lb_target_group" "frontend" {
  name        = "${var.project_name}-frontend-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"  

  health_check {
    enabled             = true
    path                = "/"          
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200-399"
  }

  tags = {
    Name = "${var.project_name}-frontend-tg"
  }
}


resource "aws_lb" "backend" {
  name               = "${var.project_name}-backend-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = module.vpc.public_subnets
}

resource "aws_lb_listener" "backend_http" {
  load_balancer_arn = aws_lb.backend.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }
}


resource "aws_lb_target_group" "backend" {
  name        = "${var.project_name}-backend-tg"
  port        = 8000
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    path                = "/"          
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    matcher             = "200"
  }

  tags = {
    Name = "${var.project_name}-backend-tg"
  }
}

//ecr
resource "aws_ecr_repository" "backend" {
  name                 = "${var.project_name}-backend"
  image_tag_mutability = "MUTABLE"   
  force_delete         = true        

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_ecr_repository" "frontend" {
  name                 = "${var.project_name}-frontend"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

//sg
# Security Group for ALB (public - allows HTTP/HTTPS from anywhere)
resource "aws_security_group" "alb_sg" {
  name        = "${var.project_name}-alb-sg"
  description = "Allow inbound HTTP/HTTPS to ALB"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-alb-sg"
    Project     = var.project_name
    Environment = var.environment
  }
}

# Security Group for ECS tasks (backend, frontend, db) - allows traffic from ALB + internal
resource "aws_security_group" "ecs_tasks_sg" {
  name        = "${var.project_name}-ecs-tasks-sg"
  description = "Allow traffic to/from ECS tasks"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "Allow traffic from ALB"
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    description = "Allow internal VPC traffic (for DB access etc.)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-ecs-tasks-sg"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_security_group_rule" "allow_db_from_ecs" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ecs_tasks_sg.id   
  source_security_group_id = aws_security_group.ecs_tasks_sg.id
}

//ecs
# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

# IAM Role for ECS Task Execution (pull images, logs, etc.)
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.project_name}-ecs-task-execution"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
resource "aws_iam_role_policy_attachment" "ecs_ssm_read" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.project_name}-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "ecs_task_ssm_read" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}


//ecs services
resource "aws_ecs_task_definition" "backend" {
  family                   = "${var.project_name}-${var.environment}-backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = tostring(var.backend_cpu)
  memory                   = tostring(var.backend_memory)
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "backend"
      image     = "${aws_ecr_repository.backend.repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 8000
          hostPort      = 8000
        }
      ]
      environment = [
        { name = "AWS_REGION",           value = var.aws_region },
        { name = "DB_USER", value = "maissen" },
        { name = "DB_NAME", value = "tododb" },
        { name = "DB_HOST", value = module.rds_postgres.db_instance_address },
        { name = "DB_PORT", value = tostring(module.rds_postgres.db_instance_port) },
      ]
      secrets = [
        {
          name = "DB_PASSWORD"
          valueFrom= aws_ssm_parameter.db_password.arn
        }  
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.project_name}-${var.environment}-backend"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "backend"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "backend" {
  name                               = "${var.project_name}-${var.environment}-backend"
  cluster                            = aws_ecs_cluster.main.id
  task_definition                    = aws_ecs_task_definition.backend.arn
  desired_count                      = var.backend_desired_count
  launch_type                        = "FARGATE"
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  load_balancer {
    target_group_arn = aws_lb_target_group.backend.arn
    container_name   = "backend"
    container_port   = 8000
  }

  network_configuration {
    subnets          = module.vpc.private_subnets
    security_groups  = [aws_security_group.ecs_tasks_sg.id]
    assign_public_ip = false
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}


resource "aws_ecs_task_definition" "frontend" {
  family                   = "${var.project_name}-${var.environment}-frontend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = tostring(var.frontend_cpu)    
  memory                   = tostring(var.frontend_memory)
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "frontend"
      image     = "${aws_ecr_repository.frontend.repository_url}:latest"
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
      environment = [
        { name = "API_URL", value = "http://${aws_lb.backend.dns_name}" }  
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${var.project_name}-${var.environment}-frontend"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "frontend"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "frontend" {
  name                               = "${var.project_name}-${var.environment}-frontend"
  cluster                            = aws_ecs_cluster.main.id
  task_definition                    = aws_ecs_task_definition.frontend.arn
  desired_count                      = var.frontend_desired_count
  launch_type                        = "FARGATE"

  load_balancer {
    target_group_arn = aws_lb_target_group.frontend.arn
    container_name   = "frontend"
    container_port   = 80
  }

  network_configuration {
    subnets          = module.vpc.private_subnets
    security_groups  = [aws_security_group.ecs_tasks_sg.id]
    assign_public_ip = false
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}
resource "aws_cloudwatch_log_group" "ecs_logs" {
  for_each = toset(["backend", "frontend"])

  name              = "/ecs/${var.project_name}-${var.environment}-${each.key}"

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}


module "rds_postgres" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 7.0"   

  identifier = "${var.project_name}-${var.environment}-postgres"

  engine               = "postgres"
  engine_version       = "15"
  instance_class       = var.rds_instance_class        
  allocated_storage    = var.rds_allocated_storage
  storage_type         = "gp2"              

  db_name  = "tododb"
  username = "maissen"  
  password_wo  = aws_ssm_parameter.db_password.value
  password_wo_version = 1
  manage_master_user_password = false

 // vpc_id               = module.vpc.vpc_id
  subnet_ids           = module.vpc.private_subnets
  vpc_security_group_ids   = [aws_security_group.rds_sg.id]   

  publicly_accessible    = false
  multi_az               = var.rds_multi_az             
  backup_retention_period = var.rds_backup_retention_period
  skip_final_snapshot    = true                
  deletion_protection    = false               

  create_db_subnet_group = true                
  create_db_parameter_group = false             

  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
  
}
resource "aws_ssm_parameter" "db_password" {
  name  = "/${var.project_name}-${var.environment}/db/password"
  type  = "SecureString"   
  value = var.db_password_ssm_value   

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}
resource "aws_security_group" "rds_sg" {
  name        = "${var.project_name}-rds-sg"
  description = "Allow inbound PostgreSQL from ECS tasks"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_tasks_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}
