output "vpc_id" {
  value = aws_vpc.Edozie_VPC.id
}

output "lb-dns" {
  value = aws_lb.Edozie_Application_Load_Balancer.dns_name
  description = "Load balancer DNS"
}