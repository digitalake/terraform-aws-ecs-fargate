# terraform-aws-ecs-fargate

In this repo You can find a Terraform code for building an AWS infra and deploying [django demo-app](https://github.com/digitalocean/sample-django) using ECS.

### Infrastructure scheme 

![Web App Reference Architecture (1)](https://github.com/digitalake/terraform-aws-ecs-fargate/assets/109740456/8b7e671a-1b53-46d2-8238-92ef37e3bea9)

### Docker. Building images

I described those steps in my previous task [here](https://github.com/digitalake/ansible-terraform-aws-django#django-and-docker).

In this case i used DockerHub, not ECR.

![image](https://github.com/digitalake/terraform-aws-ecs-fargate/assets/109740456/851e4b32-f015-4fd0-9160-f1eed98ed3ef)


### Docker. Testing images

For making sure my Docker image is ok I did use dive tool. It can be used by installing locally as well as by running inside of the [Docker container](https://github.com/wagoodman/dive):

```
docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock wagoodman/dive:latest <image>
```

The result I got is OK.

![image](https://github.com/digitalake/terraform-aws-ecs-fargate/assets/109740456/18a6e3fc-00f6-404c-acd5-3efe993c1621)

### Terraform. Infrastructure

For this task i did use a single Terraform state which is not the best option. In case of using ECS, the infra part needs to be seprated from the application part. [Oficcial Terraform AWS modules](https://registry.terraform.io/namespaces/terraform-aws-modules) were used to configure the infrastructure.

The main resources are:

- VPC and its configuration 
- ECS cluster with Fargate capacity provider
- RDS instance (Postgres engine)
- ALB

For providing the DB password to the containers as the ENV var, an AWS Secret Manager secret was used. A random password was generated for the DB instance master user and its value was used for creating an AWS Secret Manager secret. Then a secret value was extracted with the help of datasources:

```
data "aws_secretsmanager_secret" "db" {
  arn = module.db.db_instance_master_user_secret_arn
}

data "aws_secretsmanager_secret_version" "db" {
  secret_id = data.aws_secretsmanager_secret.db.id
}
```

Random password can contain special characters so while decoding a _password_ value from the secret, additional _urlencode()_ function needs to be used:

```
locals {
  ...
  app_db_password = urlencode(jsondecode(data.aws_secretsmanager_secret_version.db.secret_string)["password"])
  ...
}
```

> [!IMPORTANT]
> While implementing such approach, it's important to use state encryption.

After the succesful deployment, I had an output:

![image](https://github.com/digitalake/terraform-aws-ecs-fargate/assets/109740456/2fd13f44-0610-4a53-9b9e-aacb14aa26f9)

### RESULTS

CloudWatch log group were created to be able to check container logs. Succesful migrations:

![image](https://github.com/digitalake/terraform-aws-ecs-fargate/assets/109740456/b4daca92-5d90-4413-af32-8b1bc64bda80)

Gunicorn starting:

![image](https://github.com/digitalake/terraform-aws-ecs-fargate/assets/109740456/3c49f454-7863-4391-93e8-2f545fe0369f)

Browser LB endpoint:

![image](https://github.com/digitalake/terraform-aws-ecs-fargate/assets/109740456/0c9cd04d-59a5-4d26-b907-2514acd38768)








