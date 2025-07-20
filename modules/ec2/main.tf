# modules/ec2/main.tf

# Proxy Servers in Public Subnets
resource "aws_instance" "proxy" {
  count = length(var.public_subnet_ids)

  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  subnet_id                   = var.public_subnet_ids[count.index]
  vpc_security_group_ids      = [var.proxy_sg_id]
  associate_public_ip_address = true

  user_data = base64encode(templatefile("${path.module}/../../scripts/install-nginx.sh", {
    internal_alb_dns = var.internal_alb_dns
  }))

  tags = {
    Name = "${var.project_name}-proxy-${count.index + 1}"
    Type = "Proxy"
  }

  # Wait for the instance to be running before proceeding
  provisioner "remote-exec" {
    inline = [
      "while [ ! -f /var/log/cloud-init-output.log ]; do sleep 2; done",
      "while [ ! -f /tmp/nginx-setup-complete ]; do sleep 5; done",
      "echo 'Nginx setup completed'"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(var.private_key_path)
      host        = self.public_ip
    }
  }
}

# Backend Servers in Private Subnets
resource "aws_instance" "backend" {
  count = length(var.private_subnet_ids)

  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  subnet_id              = var.private_subnet_ids[count.index]
  vpc_security_group_ids = [var.backend_sg_id]

  user_data = base64encode(file("${path.module}/../../scripts/install-python.sh"))

  tags = {
    Name = "${var.project_name}-backend-${count.index + 1}"
    Type = "Backend"
  }
}

# File provisioner to copy Flask app to backend servers via proxy
resource "null_resource" "deploy_app" {
  count = length(aws_instance.backend)

  depends_on = [
    aws_instance.proxy,
    aws_instance.backend
  ]

  # Copy files to proxy first, then to backend
  provisioner "remote-exec" {
    inline = [
      "mkdir -p /tmp/backend-app"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(var.private_key_path)
      host        = aws_instance.proxy[0].public_ip
    }
  }

  provisioner "file" {
    source      = "${path.module}/../../backend-app/"
    destination = "/tmp/backend-app/"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(var.private_key_path)
      host        = aws_instance.proxy[0].public_ip
    }
  }

  # Copy from proxy to backend server
  provisioner "remote-exec" {
    inline = [
      "while [ ! -f /tmp/python-setup-complete ]; do sleep 5; done",
      "echo 'Python setup completed on backend server'",
    ]

    connection {
      type                = "ssh"
      user                = "ec2-user"
      private_key         = file(var.private_key_path)
      host                = aws_instance.backend[count.index].private_ip
      bastion_host        = aws_instance.proxy[0].public_ip
      bastion_user        = "ec2-user"
      bastion_private_key = file(var.private_key_path)
    }
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /tmp/backend-app"
    ]

    connection {
      type                = "ssh"
      user                = "ec2-user"
      private_key         = file(var.private_key_path)
      host                = aws_instance.backend[count.index].private_ip
      bastion_host        = aws_instance.proxy[0].public_ip
      bastion_user        = "ec2-user"
      bastion_private_key = file(var.private_key_path)
    }
  }

  provisioner "file" {
    source      = "${path.module}/../../backend-app/"
    destination = "/tmp/backend-app/"

    connection {
      type                = "ssh"
      user                = "ec2-user"
      private_key         = file(var.private_key_path)
      host                = aws_instance.backend[count.index].private_ip
      bastion_host        = aws_instance.proxy[0].public_ip
      bastion_user        = "ec2-user"
      bastion_private_key = file(var.private_key_path)
    }
  }

  # Start the Flask application
  provisioner "remote-exec" {
    inline = [
      "cd /tmp/backend-app",
      "sudo pip3 install -r requirements.txt",
      "pkill -f 'python3 app.py' || true",
      "nohup python3 app.py > /tmp/flask-app.log 2>&1 &",
      "sleep 5",
      "echo 'Flask app started'"
    ]

    connection {
      type                = "ssh"
      user                = "ec2-user"
      private_key         = file(var.private_key_path)
      host                = aws_instance.backend[count.index].private_ip
      bastion_host        = aws_instance.proxy[0].public_ip
      bastion_user        = "ec2-user"
      bastion_private_key = file(var.private_key_path)
    }
  }

  triggers = {
    backend_instance_ids = aws_instance.backend[count.index].id
    proxy_instance_ids   = aws_instance.proxy[0].id
  }
}

# Register proxy instances with public target group
resource "aws_lb_target_group_attachment" "proxy" {
  count = length(aws_instance.proxy)

  target_group_arn = var.public_target_group_arn
  target_id        = aws_instance.proxy[count.index].id
  port             = 80
}

# Register backend instances with internal target group
resource "aws_lb_target_group_attachment" "backend" {
  count = length(aws_instance.backend)

  target_group_arn = var.internal_target_group_arn
  target_id        = aws_instance.backend[count.index].id
  port             = 5000

  depends_on = [null_resource.deploy_app]
}