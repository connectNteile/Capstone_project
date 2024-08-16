module "eks" {
  source = "terraform-aws-modules/eks/aws"
  cluster_name = "1.21" 
  subnets = [aws_subnet.subnet.id]
  vpc_id = aws_vpc.main.id	
}