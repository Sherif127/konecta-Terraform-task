provider "aws" {
  region = var.region
}

module "network" {
  source             = "./modules/network"
  vpc_cidr           = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
  az                 = var.az
}

module "nginx_server" {
  source        = "./modules/ec2_nginx"
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id     = module.network.public_subnet_id
  vpc_id        = module.network.vpc_id
}
