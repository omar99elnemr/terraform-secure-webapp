resource "aws_instance" "main" {
  count = var.instance_count
  
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_ids[count.index % length(var.subnet_ids)]
  vpc_security_group_ids = [var.security_group_id]
  key_name               = var.key_name
  
  user_data = var.user_data
  
  tags = merge(var.tags, {
    Name = "${var.tags.Name}-${count.index + 1}"
  })
}