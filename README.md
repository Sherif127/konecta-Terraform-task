# Terraform Task 

This project contains two Terraform architectures (**Arch1** and **Arch2**) with modular design, remote backend state management (S3 + DynamoDB), and lifecycle rules to demonstrate advanced Terraform usage.

---

## 📌 Prerequisites
Before running this project, ensure you have:

- **AWS CLI** installed and configured  
- **Terraform** installed  
- **AWS account** with valid credentials  

---

## 1. Export AWS Credentials
Export your temporary AWS credentials to your terminal session:

```bash
export AWS_ACCESS_KEY_ID="YOUR_ACCESS_KEY"
export AWS_SECRET_ACCESS_KEY="YOUR_SECRET_KEY"
export AWS_SESSION_TOKEN="YOUR_SESSION_TOKEN"
export AWS_DEFAULT_REGION="us-east-1"
```

---

## 2. Create Backend Resources
This project uses a **remote backend (S3 + DynamoDB)** to store the Terraform state and enable state locking.

### Create S3 Bucket
```bash
aws s3api create-bucket   --bucket konecta-backend-bucket   --region us-east-1
```

### Create DynamoDB Table
```bash
aws dynamodb create-table   --table-name terraform-lock   --attribute-definitions AttributeName=LockID,AttributeType=S   --key-schema AttributeName=LockID,KeyType=HASH   --billing-mode PAY_PER_REQUEST   --region us-east-1
```

📸 **Screenshots**
- <img width="842" height="217" alt="Image" src="https://github.com/user-attachments/assets/9e4cfee1-f695-430a-88e2-56139d384eda" />
- <img width="886" height="471" alt="Image" src="https://github.com/user-attachments/assets/8e445fd4-4b05-42ea-93a2-5414e9a6c1c2" />
- <img width="1577" height="403" alt="Image" src="https://github.com/user-attachments/assets/2e887ec9-af06-45e3-9d67-58c360ee15f2" />

---

## 3. Architecture 1 (Arch1)
Arch1 provisions a complete VPC setup:

- **VPC** with public + private subnets
- **Internet Gateway + NAT Gateway**
- **Route tables** (public + private)
- **Security groups**
- **EC2 Instances**: one public (SSH + HTTP access), one private (egress only)

Variables are managed in `terraform.tfvars`.

### Run Arch1
```bash
cd arch1
terraform init
terraform apply -auto-approve
```

📸 **Screenshots**
- <img width="613" height="142" alt="Image" src="https://github.com/user-attachments/assets/9bbb4de8-a1b8-4b57-b47e-76d54942bdd5" />
- <img width="1621" height="722" alt="Image" src="https://github.com/user-attachments/assets/c7983dee-90b0-4657-a7db-f952207e57aa" />
- <img width="1562" height="210" alt="Image" src="https://github.com/user-attachments/assets/8e04865d-7071-4119-87dc-5547b8aa4d7a" />

---

## 4. Terraform Modules & Architecture 2 (Arch2)
To improve **reusability** and **maintainability**, Arch2 is built using Terraform **modules**:

- **network** → Creates VPC, public subnet, IGW, and route table.
- **ec2_nginx** → Provisions EC2 instance with Nginx installed using `user_data`.

### Run Arch2
```bash
cd arch2
terraform init 
terraform apply -auto-approve
```

📸 **Screenshots**
- <img width="583" height="110" alt="Image" src="https://github.com/user-attachments/assets/06000868-4725-4198-8e80-d83fe59026b7" />
- <img width="1920" height="1019" alt="Image" src="https://github.com/user-attachments/assets/2c45f3ce-eaee-4edb-aa8f-ea38e20288c8" />  

---

## 5. Remote State Sharing
Both **Arch1** and **Arch2** use the same **S3 + DynamoDB backend**.  
This allows safe collaboration with teammates:

- **S3** stores the state file.
- **DynamoDB** ensures state locking (only one `terraform apply` at a time).

📸 **Screenshots to include here:**
- <img width="1129" height="436" alt="Image" src="https://github.com/user-attachments/assets/9134bcd1-9264-4732-9830-e3cb8860e7f2" />

---

## 6. Destroy Arch1 Without Deleting EC2
To destroy Arch1 but **keep the EC2 instance alive**, we removed it from the Terraform state:

```bash
terraform state rm aws_instance.private_ec2
terraform state rm aws_security_group.private_sg
terraform state rm aws_subnet.private
terraform state rm aws_vpc.main
terraform destroy -var-file="terraform.tfvars" -auto-approve
```

This leaves the EC2 instance (and dependencies) as **orphan resources** in AWS.

📸 **Screenshots to include here:**
- <img width="499" height="90" alt="Image" src="https://github.com/user-attachments/assets/e69edb2c-5476-4f83-86b3-bbd29c3b5f9d" />
- <img width="881" height="240" alt="Image" src="https://github.com/user-attachments/assets/dbda3c83-e0a9-42a0-8f47-307ab345cdb6" />

---

## 7. Prevent NAT Gateway Deletion
To protect the NAT Gateway from being deleted even during `terraform destroy`, we used the lifecycle rule:

```hcl
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id

  lifecycle {
    prevent_destroy = true
  }
}
```

---

## ✅ Summary
- **Arch1** → Classic VPC + Public/Private EC2 setup.  
- **Arch2** → Modular approach with Network + Nginx module.  
- **Remote Backend** → S3 bucket + DynamoDB for collaboration and locking.  
- **Task 5** → Kept EC2 instance alive while destroying other resources.  
- **Task 6** → Protected NAT Gateway with lifecycle rules.  
