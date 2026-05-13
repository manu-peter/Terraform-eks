output "bastion_sg_id" { value = aws_security_group.bastion_sg.id }
output "cluster_sg_id" { value = aws_security_group.cluster_sg.id }
output "endpoint_sg_id" { value = aws_security_group.endpoint_sg.id }
