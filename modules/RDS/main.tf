
# for production eith aws_rds_cluster, rds cluster instance or rds db instance with  multi az true
# for production:
# backup_retention_period = 7
#   preferred_backup_window = "07:00-09:00"
#   preferred_maintenance_window = "sun:04:00-sun:06:00"
# RDS instance for development/testing
resource "aws_db_instance" "db_instance" {
  identifier        = var.identifier
  instance_class    = var.instance_class
  engine            = var.engine
  engine_version    = var.engine_version     
  username          = var.username
  password          = var.db_password
  db_name           = var.db_name

  allocated_storage = var.allocated_storage          # Reduced for dev/test
  storage_type      = var.storage_type          
  multi_az          = var.multi_az
  publicly_accessible = var.publicly_accessible
  skip_final_snapshot = var.skip_final_snapshot

  db_subnet_group_name    = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.db_sg.id]
}

# Subnet group for the DB
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = var.db_subnet_group
  subnet_ids = var.subnets_private
}

# Security Group for the DB
resource "aws_security_group" "db_sg" {
  name        = var.db_sg
  description = "Security group for RDS DB instance"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]  # Adjust CIDR block for your VPC configuration
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



# SQL file execution on startup
resource "null_resource" "init_sql" {
  provisioner "local-exec" {
    command = "PGPASSWORD=${var.db_password} psql -h ${aws_db_instance.db_instance.address} -U backend -d deeplinkurl -f ../../modules/RDS/test_dl.sql"
  }
}
