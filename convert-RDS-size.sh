#!/bin/bash

# Variables
DB_INSTANCE_IDENTIFIER="test-jump-rds"   # replace with your RDS instance name
REGION="ap-south-1"                            # replace with your region

echo "Do you want to increase or decrease RDS size?"
echo "1. Increase"
echo "2. Decrease"
read -p "Enter choice (1 or 2): " ACTION

echo "Choose new instance size:"
echo "1. db.t4g.micro"
echo "2. db.t4g.large"
echo "3. db.t4g.xlarge"
echo "4. db.t3.large"
echo "5. db.t3.xlarge"
read -p "Enter choice (1-4): " SIZE_CHOICE

# Map choice to instance type
case $SIZE_CHOICE in
  1) NEW_SIZE="db.t4g.micro" ;;
  2) NEW_SIZE="db.t4g.large" ;;
  3) NEW_SIZE="db.t4g.xlarge" ;;
  4) NEW_SIZE="db.t3.large" ;;
  5) NEW_SIZE="db.t3.xlarge" ;;
  *) echo "Invalid choice"; exit 1 ;;
esac

# Get current instance size
CURRENT_SIZE=$(aws rds describe-db-instances \
  --db-instance-identifier $DB_INSTANCE_IDENTIFIER \
  --region $REGION \
  --query "DBInstances[0].DBInstanceClass" \
  --output text)

echo "Current RDS size: $CURRENT_SIZE"
echo "Requested new size: $NEW_SIZE"

# Compare sizes
if [ "$CURRENT_SIZE" == "$NEW_SIZE" ]; then
  echo "RDS is already using $CURRENT_SIZE. No changes required."
  exit 0
fi

# Update RDS instance type
echo "Updating RDS instance size from $CURRENT_SIZE to $NEW_SIZE..."
aws rds modify-db-instance \
  --db-instance-identifier $DB_INSTANCE_IDENTIFIER \
  --db-instance-class $NEW_SIZE \
  --apply-immediately \
  --region $REGION

if [ $? -eq 0 ]; then
  echo "RDS instance update initiated successfully."
else
  echo "Failed to update RDS instance."
fi
