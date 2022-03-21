# Creacion del cluster
resource "aws_eks_cluster" "eks_cluster" {
  name     = "KuberCluster"
  role_arn = aws_iam_role.iam-role-eks-cluster.arn
  version  = "1.21"

  # VPC para el Cluster
  vpc_config {
    security_group_ids = ["${aws_security_group.eks-cluster.id}"]
    subnet_ids         = ["${aws_subnet.priv-subnet-1.id}", "${aws_subnet.priv-subnet-2.id}"]
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-cluster-AmazonEKSClusterPolicy # El rol de IAM correspondiente para su funcionamiento
  ]
}


# Creacion del node group
resource "aws_eks_node_group" "node" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "Group_ngnix"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = ["${aws_subnet.priv-subnet-1.id}", "${aws_subnet.priv-subnet-2.id}"]
  ami_type        = "AL2_x86_64"
  instance_types  = ["t2.micro"]
  disk_size       = "5"
  scaling_config {
    desired_size = 4
    max_size     = 6
    min_size     = 2
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}