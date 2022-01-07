data "template_cloudinit_config" "lb" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content = templatefile("./templates/lb/cloud-init.yaml", {
      nginx_version = var.nginx_version
      provision_content = base64gzip(templatefile("./templates/provision.sh", {
        region = var.region
      }))
      compose_content = base64gzip(templatefile("./templates/lb/compose.yml", {
        nginx_version = var.nginx_version
      }))
      nginx_content = base64gzip(templatefile("./templates/lb/nginx.conf", {
        nginx_proxy = aws_service_discovery_private_dns_namespace.main.name
      }))
    })
  }
}

resource "aws_security_group" "lb-security" {
  name        = "allow_http"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "HTTP from Internet"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_http"
  }
}

resource "aws_instance" "lb-main" {
  ami           = "ami-002068ed284fb165b" # TODO: Use datasource / variable
  instance_type = "t2.nano"
  subnet_id     = aws_subnet.main.id
  vpc_security_group_ids = [
    aws_security_group.lb-security.id
  ]
  associate_public_ip_address = true
  user_data_base64 = data.template_cloudinit_config.lb.rendered

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 10
    delete_on_termination = true
    encrypted             = true
  }

  # TODO: Associate billing tags
  tags = {
    Name : "nginx-lb"
  }

}


