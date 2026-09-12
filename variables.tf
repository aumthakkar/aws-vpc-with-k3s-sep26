variable "vpc_cidr" {}
variable "name_prefix" {}

variable "public_subnet_count" {}
variable "private_subnet_count" {}

variable "auto_create_public_cidr_block" {}
variable "auto_create_private_cidr_block" {}
variable "custom_public_cidr_blocks" {}
variable "custom_private_cidr_blocks" {}

# DB related Variables

variable "db_name" {}
variable "db_identifier" {}

variable "db_username" {}
variable "db_password" {}

variable "db_engine" {}
variable "db_engine_version" {}

variable "db_instance_class" {}
variable "db_allocated_storage" {}

# LaadBalancer Variables
variable "lb_target_port" {}
variable "lb_target_protocol" {}

variable "lb_target_healthy_threshold" {}
variable "lb_target_unhealthy_threshold" {}
variable "lb_target_interval" {}
variable "lb_target_timeout" {}

variable "lb_listener_port" {}
variable "lb_listener_protocol" {}

# Compute Variables
variable "k3s_instance_count" {}
variable "k3s_instance_type" {}

variable "k3s_instance_key_name" {}
variable "k3s_instance_vol_size" {}


