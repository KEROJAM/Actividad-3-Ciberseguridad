# 1. Bucket S3 simulado.
resource "aws_s3_bucket" "seguro" {
  bucket = "actividad3-seguro-local"

  # Facilita la limpieza del laboratorio aunque el bucket tenga objetos.
  force_destroy = true

  tags = {
    Name        = "actividad3-seguro-local"
    Environment = "local"
    ManagedBy   = "Terraform"
  }
}

# 2. Cifrado por defecto SSE-S3 con AES-256.
resource "aws_s3_bucket_server_side_encryption_configuration" "seguro" {
  bucket = aws_s3_bucket.seguro.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# 3. Los cuatro controles de bloqueo de acceso público.
resource "aws_s3_bucket_public_access_block" "seguro" {
  bucket = aws_s3_bucket.seguro.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
