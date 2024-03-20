module "vpc" {
  source               = "./modules/vpc"
}

module "autoscaling_group" {
  source = "./modules/asg"
  vpc_id                  = module.vpc.vpc_id
  alb_security_group_id = [module.alb.alb_security_group_id]
  public_subnet_ids     = module.vpc.public_subnet_ids
  target_group_arn      = [module.alb.target_group_arn]
}

module "alb" {
  source              = "./modules/alb"
  vpc_id              = module.vpc.vpc_id
  public_subnet_ids   = module.vpc.public_subnet_ids
}

