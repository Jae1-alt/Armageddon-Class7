resource "aws_db_subnet_group" "rds_private_group" {
  name        = "lab-rds-private-subnet-group"
  description = "RDS Subnet Group for lab using private subnets"

  subnet_ids = [for id in module.main_vpc.private_subnet_id : id]

  tags = merge(var.tags, { Name = "Lab DB Subnet Group" })
}

resource "aws_db_instance" "mysql_db" {

  identifier        = aws_ssm_parameter.paramters["/lab/db/name"].value
  allocated_storage = 20
  engine            = var.engine
  engine_version    = "8.0"
  instance_class    = "db.t3.micro"

  username = var.db_username
  password = var.db_password
  port     = aws_ssm_parameter.paramters["/lab/db/port"].value

  db_subnet_group_name   = aws_db_subnet_group.rds_private_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  publicly_accessible    = false

  skip_final_snapshot = true
  deletion_protection = false

  tags = var.tags
}