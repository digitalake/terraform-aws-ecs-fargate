module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.1.1"

  identifier                     = var.db_identifier
  instance_use_identifier_prefix = var.db_instance_use_identifier_prefix

  create_db_option_group    = false
  create_db_parameter_group = false

  engine         = var.db_engine
  engine_version = var.db_engine_version
  instance_class = var.db_instance_class

  allocated_storage = var.db_allocated_storage

  db_name  = var.db_name
  username = var.db_user
  port     = var.db_port

  manage_master_user_password = true
  storage_encrypted           = var.db_storage_encrypted # option just for using small t2.micro 

  db_subnet_group_name   = module.vpc.database_subnet_group
  vpc_security_group_ids = [module.db-sg.security_group_id]

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Role        = "db"
  }
}

module "db-sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"

  name        = "db-sg"
  description = "Security group for the Postgres instances"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = var.db_port
      to_port     = var.db_port
      protocol    = "tcp"
      description = "PostgreSQL access from within VPC"
      cidr_blocks = module.vpc.private_subnets_cidr_blocks[0]
    }
  ]

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}



