resource "aws_db_instance" "default" {
  allocated_storage   = 10
  db_name             = "mydb"
  engine              = "aurora-postgresql"
  engine_version      = "12.8"
  instance_class      = "db.t3.micro"
  multi_az            = false
  username            = var.db_username
  password            = var.db_password
  skip_final_snapshot = true
}
