data "template_cloudinit_config" "app" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content = templatefile("./templates/app/cloud-init.yaml", {
      nginx_version = var.nginx_version
      provision_content = base64gzip(templatefile("./templates/provision.sh", {
        region = var.region
      }))
      compose_content = base64gzip(templatefile("./templates/app/compose.yml", {
        nginx_version = var.nginx_version
      }))
      nginx_content = base64gzip(templatefile("./templates/app/nginx.conf", {
        nginx_proxy = "httpbin.org"
      }))
      html_content = base64gzip(templatefile("./templates/app/index.html", { }))
    })
  }
}

resource "aws_security_group" "app-security" {
  name        = "allow_http_app"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "HTTP from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    # TODO: Use CIDR from VPC
    # cidr_blocks      = [aws_vpc.main.cidr_block]
    # ipv6_cidr_blocks = [aws_vpc.main.ipv6_cidr_block]
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

resource "aws_instance" "app-main" {
  ami           = var.ami
  instance_type = "t2.nano"
  subnet_id     = aws_subnet.main.id
  vpc_security_group_ids = [
    aws_security_group.app-security.id
  ]
  user_data_base64 = data.template_cloudinit_config.app.rendered

  root_block_device {
    volume_type           = "gp2"
    volume_size           = 10
    delete_on_termination = true
    encrypted             = true
  }

  # TODO: Associate billing tags
  tags = {
    Name : "nginx-app"
  }

}


