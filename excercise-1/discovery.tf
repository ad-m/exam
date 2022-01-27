
resource "aws_service_discovery_private_dns_namespace" "main" {
  name        = "main.terraform.local"
  description = "main"
  vpc         = aws_vpc.main.id
}

resource "aws_service_discovery_service" "main" {
  name = "main"

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.main.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

resource "aws_service_discovery_instance" "main" {
  instance_id = "main-instance-id"
  service_id  = aws_service_discovery_service.main.id

  attributes = {
    AWS_EC2_INSTANCE_ID = aws_instance.app-main[count.index].id
  }
  count = length(aws_instance.app-main)

}
