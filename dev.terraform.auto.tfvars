vpc_cidr    = "10.0.0.0/16"
name_prefix = "pht-dev"

public_subnet_count  = 2
private_subnet_count = 2

auto_create_public_cidr_block  = true
auto_create_private_cidr_block = true
custom_public_cidr_blocks      = []
custom_private_cidr_blocks     = []

db_name       = "rancher"
db_identifier = "rancher"

db_username = "pranav"
db_password = "t4b!3s2026"

db_engine         = "mysql"
db_engine_version = "8.0.45"

db_instance_class    = "db.t3.micro"
db_allocated_storage = 50

# LB variables

lb_target_port     = 8000
lb_target_protocol = "HTTP"

lb_target_healthy_threshold   = 3
lb_target_unhealthy_threshold = 3
lb_target_interval            = 30
lb_target_timeout             = 10

lb_listener_port     = 80
lb_listener_protocol = "HTTP"

k3s_instance_count = 1
k3s_instance_type  = "t4g.small"

k3s_instance_key_name = "mtckey"
k3s_instance_vol_size = 10


