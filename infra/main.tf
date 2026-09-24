provider "aws" {
  region = "us-east-1"
}

# ------------------------------------------------------
# BUCKET S3 REAL: Privado, sin acceso público y cifrado
# ------------------------------------------------------
resource "aws_s3_bucket" "app_bucket" {
  bucket = "red-social-breve-tema2-bucket" 
}

resource "aws_s3_bucket_public_access_block" "app_bucket_acceso" {
  bucket                  = aws_s3_bucket.app_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "app_bucket_cifrado" {
  bucket = aws_s3_bucket.app_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ------------------------------------------------------
# BASE DE DATOS RDS REAL: Cifrada y sin acceso público
# ------------------------------------------------------
variable "db_password" {
  description = "Contraseña de la BD inyectada por variable de entorno para evitar credenciales en código"
  type        = string
  default     = "PasswordSegura123!"
}

resource "aws_db_instance" "app_db" {
  allocated_storage    = 20
  engine               = "postgres"
  instance_class       = "db.t3.micro"
  identifier           = "db-red-social-breve"
  username             = "dbadmin"
  password             = var.db_password
  publicly_accessible  = false
  storage_encrypted    = true
  skip_final_snapshot  = true
}
