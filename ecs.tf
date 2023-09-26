data "aws_secretsmanager_secret" "db" {
  arn = module.db.db_instance_master_user_secret_arn
}

data "aws_secretsmanager_secret_version" "db" {
  secret_id = data.aws_secretsmanager_secret.db.id
}

locals {
  app_db_username = module.db.db_instance_username
  app_db_password = urlencode(jsondecode(data.aws_secretsmanager_secret_version.db.secret_string)["password"])
  app_db_host     = module.db.db_instance_address
  app_db_name     = module.db.db_instance_name
  app_db_port     = module.db.db_instance_port
  app_db_url      = "postgres://${local.app_db_username}:${local.app_db_password}@${local.app_db_host}:${local.app_db_port}/${local.app_db_name}"
}

module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "5.2.2"

  cluster_name = var.ecs_cluster_name

  create_cloudwatch_log_group = var.ecs_create_cloudwatch_log_group ## change me

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 100
        base   = 20
      }
    }
  }

  services = {
    "${var.ecs_service_name}" = {
      cpu    = var.ecs_service_cpu
      memory = var.ecs_service_memory

      # Container definition(s)
      container_definitions = {
        "${var.ecs_container_name}" = {
          cpu    = var.ecs_service_cpu
          memory = var.ecs_service_memory
          image  = var.ecs_container_image
          port_mappings = [
            {
              name          = var.ecs_container_port_name
              containerPort = var.ecs_container_port
              hostPort      = var.ecs_container_port
              protocol      = "tcp"
            }
          ]

          environment = [
            {
              name  = "DEBUG"
              value = "true"
            },
            {
              name  = "DATABASE_URL"
              value = local.app_db_url
            },
            {
              name  = "DJANGO_ALLOWED_HOSTS"
              value = "*"
            }
          ]

          readonly_root_filesystem = false

          enable_cloudwatch_logging = true ## change me

          memory_reservation = 100
        }
      }

      service_connect_configuration = {
        namespace = aws_service_discovery_http_namespace.this.arn
        service = {
          client_alias = {
            port     = var.ecs_container_port
            dns_name = var.ecs_container_port_name
          }
          port_name      = var.ecs_container_port_name
          discovery_name = var.ecs_container_port_name
        }
      }

      load_balancer = {
        service = {
          target_group_arn = element(module.alb.target_group_arns, 0)
          container_name   = var.ecs_container_name
          container_port   = var.ecs_container_port
        }
      }

      subnet_ids = [module.vpc.private_subnets[0]]

      security_group_rules = {
        alb_ingress = {
          type                     = "ingress"
          from_port                = var.ecs_container_port
          to_port                  = var.ecs_container_port
          protocol                 = "tcp"
          description              = "Service port"
          source_security_group_id = module.alb.security_group_id
        }
        egress_all = {
          type        = "egress"
          from_port   = 0
          to_port     = 0
          protocol    = "-1"
          cidr_blocks = ["0.0.0.0/0"]
        }
      }
    }
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Role        = "app"
  }

}

resource "aws_service_discovery_http_namespace" "this" {
  name        = "test"
  description = "CloudMap namespace"
  tags = {
    Terraform   = "true"
    Environment = "dev"
    Role        = "NS"
  }
}