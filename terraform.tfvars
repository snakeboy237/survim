aws_region  = "us-east-1"
aws_profile = "default"

s3_buckets_map = {
    bucket1 = "temp-image-bucket"   
    bucket2 = "final-image-bucket"
}
environment          = "dev"

kafka_cluster_name = "dev-kafka-cluster"
kafka_broker_count = 3

kafka_sg_id       = "sg-12345678"