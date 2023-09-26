output "lb_dns" {
  value = module.alb.lb_dns_name
}

output "db_endpoint" {
  value = module.db.db_instance_endpoint
}

output "db_instance_address" {
  value = module.db.db_instance_address
}