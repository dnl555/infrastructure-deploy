resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = [aws_subnet.private_subnets[0].id, aws_subnet.private_subnets[1].id]

  tags = {
    Name = "My DB subnet group"
  }
}

resource "aws_db_instance" "default" {
  db_name              = "mydb"
  allocated_storage    = 10
  engine               = "postgres"
  engine_version       = "12.7"
  instance_class       = "db.t2.micro"
  multi_az             = false
  username             = var.db_username
  password             = var.db_password
  db_subnet_group_name = aws_db_subnet_group.default.name
  skip_final_snapshot  = true
}

