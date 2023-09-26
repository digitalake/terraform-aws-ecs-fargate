# VPC  module vars

variable "vpc_name" {
  type        = string
  description = "name for primary VPC"
  default     = "main"
}

variable "vpc_cidr" {
  type        = string
  description = "CODR block for primary VPC"
  default     = "10.0.0.16"
}

variable "vpc_azs" {
  type        = list(string)
  description = "Avaliability zones for the primary VPC"
  default     = ["us-east-1a", "us-east-1b"]
}

variable "vpc_private_subnets" {
  type        = list(string)
  description = "Private subnet CIDRs"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "vpc_public_subnets" {
  type        = list(string)
  description = "Public subnet CIDRs. Make sure to specify at leats 2 public subnets in two azs for ALB"
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "vpc_database_subnets" {
  type        = list(string)
  description = "Databse subnet CIDRS"
  default     = ["10.0.201.0/24", "10.0.202.0/24"]
}

variable "vpc_database_subnet_group_name" {
  type        = string
  description = "A name for DB subnet group"
  default     = "application-db"
}

variable "vpc_enable_nat_gateway" {
  type        = bool
  description = "Enable or disable NAT for private subnets"
  default     = true
}

variable "vpc_single_nat_gateway" {
  type        = bool
  description = "Enable or disable single NAT"
  default     = false
}

# ECS module variables

variable "ecs_cluster_name" {
  type        = string
  description = "A name fo the ECS cluster"
  default     = "default"
}

variable "ecs_create_cloudwatch_log_group" {
  type        = bool
  description = "Define if seperate CW target group should be created"
  default     = true
}

variable "ecs_service_name" {
  type        = string
  description = "A name for serivce will be deployed"
  default     = "default"
}

variable "ecs_service_cpu" {
  type        = number
  description = "A number of cpu (1024 = 1 vcpu)"
  default     = 1024
}

variable "ecs_service_memory" {
  type        = number
  description = "A number of memory to allocate"
  default     = 4096
}

variable "ecs_container_name" {
  type        = string
  description = "Container name for task definition"
  default     = "default"
}

variable "ecs_container_port" {
  type    = number
  default = 8000
}

variable "ecs_container_image" {
  type        = string
  description = "A registry image adress: registry/image:tag"
  default     = "nginx"
}

variable "ecs_container_port_name" {
  type        = string
  description = "A name to use for port configs"
  default     = "default"
}







# ALB module variables

variable "alb_name" {
  type        = string
  description = "Application load balancer name"
  default     = "application-lb"
}

variable "alb_security_group_name" {
  type        = string
  description = "A name for the Security Group to attach to LB"
  default     = "alb-sg"
}

variable "alb_traffic_port" {
  type        = number
  description = "Port for LB to work on"
  default     = 80
}


# PostgresDB module variables

variable "db_identifier" {
  type        = string
  description = "An identefier to assign to the DB instance"
  default     = "application"
}

variable "db_instance_use_identifier_prefix" {
  type        = bool
  description = "Define if identifier is used as a prefix"
  default     = true
}

variable "db_engine" {
  type        = string
  description = "An engine for DB instance"
  default     = "postgres"
}

variable "db_engine_version" {
  type        = string
  description = "An engine version for DB instance"
  default     = "12"
}

variable "db_instance_class" {
  type        = string
  description = "An instance type for DB instance"
  default     = "db.t2.micro" # !!! Use db.t2.micro only with storage_encrypted = false
}

variable "db_allocated_storage" {
  type        = number
  description = "A number of GBs to allocate as a storage"
  default     = 5
}

variable "db_storage_encrypted" {
  type        = bool
  description = "Define if DB storage needs encryption"
  default     = true
}

variable "db_name" {
  type        = string
  description = "Database name"
  default     = "application_db"
}

variable "db_user" {
  type        = string
  description = "Database user"
  default     = "application_user"
}

variable "db_port" {
  type        = number
  description = "DB connection port for Postgres"
  default     = 5432
}

