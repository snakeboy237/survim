# ------------------------------------------------------------------------------------------------------------------------------
# AWS MSK (Kafka) Cluster
# This Terraform configuration creates an AWS Managed Streaming for Kafka (MSK) cluster.
# The Kafka cluster will be used for real-time messaging between components:
# - Lambda will produce messages when images arrive in S3
# - AI Detection service will consume messages from Kafka topics
# The Kafka brokers will run in the Kafka Private Subnet.
# ------------------------------------------------------------------------------------------------------------------------------

resource "aws_msk_cluster" "kafka_cluster" {
  cluster_name           = var.kafka_cluster_name
  kafka_version          = "3.5.1" # You can adjust to latest supported version
  number_of_broker_nodes = 2       # You can increase to 3 for production HA

  broker_node_group_info {
    instance_type = "kafka.m5.large"

    client_subnets = [
      aws_subnet.private_subnet_kafka.id,
      aws_subnet.private_subnet_db.id,
      aws_subnet.private_subnet_ai.id
    ]

    security_groups = [
      aws_security_group.kafka_sg.id
    ]

    storage_info {
      ebs_storage_info {
        volume_size = 1 # GB per broker — adjust as needed
      }
    }
  }

  encryption_info {
    encryption_in_transit {
      client_broker = "TLS"   # Enforce encrypted traffic between clients and brokers
      in_cluster    = true    # Enforce encryption between brokers
    }
  }

}

/*
  configuration_info {
    arn      = var.kafka_configuration_arn # Optional — reference to a Kafka config
    revision = var.kafka_configuration_revision 
  }

  tags = {
    Name        = var.kafka_cluster_name
    Environment = var.environment
  }
}

*/
