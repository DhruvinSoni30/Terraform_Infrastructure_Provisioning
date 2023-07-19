# Geting the name of directory in which the last commit has done
DIRNAME=$(git log -1 --name-only --pretty=format:'' | xargs -n1 dirname | sort -u | head -1 | cut -d'/' -f2)

# Checking whether the folder already has a file or not 
file=$(aws s3 ls s3://stack-definition/$DIRNAME/ | grep "provider.tf")
code=$?

if [ $code != 0 ]; then
    # Generating the provider.tf file   
    cat > provider.tf << EOF
    # configure aws provider
    provider "aws" {
      region  = var.region
      profile = "dhsoni"
    }

    # configuring backend
    terraform {
    backend "s3" {
        bucket         = "dhsoni-terraform"
        key            = "$DIRNAME/terraform.tfstate"
        region         = "us-east-2"
        profile        = "dhsoni"
        dynamodb_table = "terraform-state-lock-dynamodb"
      }
    }
EOF
    # Uploading the provider.tf file on S3
    aws s3 cp provider.tf s3://stack-definition/$DIRNAME/provider.tf
else
    echo "Done" > /dev/null
fi