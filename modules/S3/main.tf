resource "aws_s3_bucket" "primary_frontend" {
  bucket = var.primary_bucket_name_frontend
  acl    = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}
resource "aws_s3_bucket_policy" "oai_policy_primary" {
    for_each = {
    "${aws_s3_bucket.primary_frontend.id}"  = aws_s3_bucket.primary_frontend.arn,
    
    "${aws_s3_bucket.primary_landing.id}"  = aws_s3_bucket.primary_landing.arn,
    
  }
  bucket = each.key
  policy = jsonencode({
   Version = "2012-10-17",
   Statement=[{
    Effect="Allow"
    Action=["s3:GetObject"]
    Principal = {"AWS": "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${var.oai_id}"},
    Resource  = "${each.value}/*"
   }]
  })
}
resource "aws_s3_bucket_policy" "oai_policy_failover" {
    for_each = {
    
    "${aws_s3_bucket.failover_frontend.id}"  = aws_s3_bucket.failover_frontend.arn,
    
    "${aws_s3_bucket.failover_landing.id}"  = aws_s3_bucket.failover_landing.arn
  }
  provider = aws.euc
  bucket = each.key
  policy = jsonencode({
   Version = "2012-10-17",
   Statement=[{
    Effect="Allow"
    Action=["s3:GetObject"]
    Principal = {"AWS": "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity ${var.oai_id}"},
    Resource  = "${each.value}/*"
   }]
  })
}
resource "aws_s3_bucket" "primary_landing" {
  bucket = var.primary_bucket_name_landing
  acl    = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket" "failover_frontend" {
  provider = aws.euc
  bucket   = var.failover_bucket_name_frontend
  acl      = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}
resource "aws_s3_bucket" "failover_landing" {
  provider = aws.euc
  bucket   = var.failover_bucket_name_landing
  acl      = "private"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}
resource "aws_iam_role" "replication" {
  name = "s3-replication-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_s3_bucket_replication_configuration" "replication_primary" {
  bucket = aws_s3_bucket.primary_frontend.id

  role = aws_iam_role.replication.arn

  rule {
    id     = "replicateAll"  # A unique identifier for the rule
    status = "Enabled"
    priority = 1  # Required if there could potentially be multiple rules

    filter {
      prefix = ""  # An empty prefix means replicate all objects
    }
    delete_marker_replication {
      status = "Enabled"
    }

    destination {
      bucket        = aws_s3_bucket.failover_frontend.arn
      storage_class = "STANDARD"
    }
  }
}
resource "aws_s3_bucket_replication_configuration" "replication_landing" {
  bucket = aws_s3_bucket.primary_landing.id

  role = aws_iam_role.replication.arn

  rule {
    id     = "replicateAll"  # A unique identifier for the rule
    status = "Enabled"
    priority = 1  # Required if there could potentially be multiple rules

    filter {
      prefix = ""  # An empty prefix means replicate all objects
    }
    delete_marker_replication {
      status = "Enabled"
    }

    destination {
      bucket        = aws_s3_bucket.failover_landing.arn
      storage_class = "STANDARD"
    }
  }
}

