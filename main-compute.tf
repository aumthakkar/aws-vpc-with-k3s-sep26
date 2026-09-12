data "aws_ami" "my_ubuntu_ami" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-resolute-26.04-arm64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "my_k3s_instance_key_pair" {
  key_name = var.k3s_instance_key_name

  public_key = "${path.module}/mtckey.pub"
  tags = {
    Name = "${var.name_prefix}-public-key"
  }
}

resource "random_id" "my_k3s_instance_id" {
  byte_length = 2

}

resource "aws_instance" "my_k3s_instance" {
  count = var.k3s_instance_count

  ami           = data.aws_ami.my_ubuntu_ami.id
  instance_type = var.k3s_instance_type

  key_name = aws_key_pair.my_k3s_instance_key_pair.key_name

  user_data = templatefile("${path.module}/scripts/userdata.tftpl",
    {
      db_user     = var.db_username,
      db_password = var.db_password,
      db_name     = var.db_name
      db_endpoint = aws_db_instance.my_db_instance.endpoint
      nodename    = "${var.name_prefix}-k3s-instance-${random_id.my_k3s_instance_id.dec}"
    }
  )

  subnet_id       = aws_subnet.my_public_subnets[count.index].id
  security_groups = [aws_security_group.my_security_groups["public"].id]

  root_block_device {
    volume_size = var.k3s_instance_vol_size
  }

  tags = {
    Name = "${var.name_prefix}-k3s-instance-${random_id.my_k3s_instance_id.dec}"
  }
}

resource "aws_lb_target_group_attachment" "my_lb_target_group_attachment" {
  count = var.k3s_instance_count

  target_group_arn = aws_lb_target_group.my_lb_target_group.arn

  target_id = aws_instance.my_k3s_instance[count.index].id
  port      = var.lb_target_port
}