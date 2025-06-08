output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main_vpc.id
}

output "public_subnet_id" {
  value = aws_subnet.public_subnet.id
}

output "private_subnet_ai_id" {
  value = aws_subnet.private_subnet_ai.id
}

output "private_subnet_db_id" {
  value = aws_subnet.private_subnet_db.id
}

output "private_subnet_kafka_id" {
  value = aws_subnet.private_subnet_kafka.id
}

output "s3_temp_bucket_name" {
  value = aws_s3_bucket.buckets["bucket1"].bucket
}

output "s3_final_bucket_name" {
  value = aws_s3_bucket.buckets["bucket2"].bucket
}

output "eks_cluster_name" {
  value = aws_eks_cluster.eks_cluster.name
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.eks_cluster.endpoint
}

output "eks_cluster_ca_certificate" {
  value = aws_eks_cluster.eks_cluster.certificate_authority[0].data
}
output "kafka_cluster_name" {
  value = aws_msk_cluster.kafka_cluster.cluster_name
}