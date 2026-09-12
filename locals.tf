locals {
  public_subnet_cidr  = [for i in range(0, 255, 2) : cidrsubnet(var.vpc_cidr, 8, i)]
  private_subnet_cidr = [for i in range(1, 255, 2) : cidrsubnet(var.vpc_cidr, 8, i)]
}

locals {
  public_subnet_cidr_block  = var.auto_create_public_cidr_block ? local.public_subnet_cidr : var.custom_public_cidr_blocks
  private_subnet_cidr_block = var.auto_create_private_cidr_block ? local.private_subnet_cidr : var.custom_private_cidr_blocks
}

locals {
  my_security_groups = {
    public = {
      name        = "${var.name_prefix}-public-security-group"
      description = "Public Security Group"
      tags = {
        Name = "${var.name_prefix}-public-security-group"
      }
      ingress = {
        ssh = {
          from        = 22
          to          = 22
          cidr_blocks = ["0.0.0.0/0"]
          protocol    = "tcp"
        }
        http = {
          from        = 80
          to          = 80
          cidr_blocks = ["0.0.0.0/0"]
          protocol    = "tcp"
        }
        nginx = {
          from        = 8000
          to          = 8000
          cidr_blocks = ["0.0.0.0/0"]
          protocol    = "tcp"
        }
      }
    }
    rds = {
      name        = "${var.name_prefix}-database-security-group"
      description = "Database Security Group"
      tags = {
        Name = "${var.name_prefix}-database-security-group"
      }
      ingress = {
        ssh = {
          from        = 3306
          to          = 3306
          cidr_blocks = [var.vpc_cidr]
          protocol    = "tcp"
        }
      }
    }
  }
} 