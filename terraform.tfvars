# Account configuration
aws_region     = "ca-central-1"
aws_access_key = "YOUR_ACCESS_KEY"
aws_secret_key = "YOUR_SECRET_ACCESS_KEY"

# Network
availability_zones = ["ca-central-1a", "ca-central-1b"]
public_subnets     = ["10.10.100.0/24", "10.10.101.0/24"]
private_subnets    = ["10.10.0.0/24", "10.10.1.0/24"]

# Tags
app_name        = "python-app"
app_environment = "production"