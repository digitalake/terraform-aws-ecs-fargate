module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name = var.vpc_name
  cidr = var.vpc_cidr

  azs                        = var.vpc_azs
  private_subnets            = var.vpc_private_subnets
  public_subnets             = var.vpc_public_subnets
  database_subnets           = var.vpc_database_subnets
  database_subnet_group_name = var.vpc_database_subnet_group_name

  enable_nat_gateway = var.vpc_enable_nat_gateway
  single_nat_gateway = var.vpc_single_nat_gateway
}
