resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = [aws_subnet.private_subnets[0].id, aws_subnet.private_subnets[1].id]

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_db_instance" "default" {
  allocated_storage    = 25
  name                 = "mydb"
  engine               = "aurora-postgresql"
  engine_version       = "11.15"
  instance_class       = "db.t4g.medium"
  multi_az             = false
  username             = var.db_username
  password             = var.db_password
  db_subnet_group_name = aws_db_subnet_group.default.name
  skip_final_snapshot  = true
}

