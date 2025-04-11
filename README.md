# 🚀 ShopEase LTD Cloud Migration Project

## Overview

This project involves the migration of ShopEase LTD's infrastructure to AWS. The goal is to build a **secure, scalable, and highly available** cloud-based e-commerce infrastructure.

## ShopEase LTD Cloud Infrastructure - Using Terraform 

This project provisions a secure, scalable, and highly available AWS infrastructure for **ShopEase LTD**, an e-commerce platform. It uses **Terraform** to define infrastructure as code (IaC), enabling consistent, repeatable deployments and team collaboration.

## 🛠️ Prerequisites

- [Terraform CLI](https://developer.hashicorp.com/terraform/downloads)
- AWS CLI configured (`aws configure`)
- AWS account with IAM access
- SSH key pair (public key for bastion host access)

---

## 🛠️ Tools & Technologies
- AWS VPC, EC2, RDS, ALB, Auto Scaling
- Terraform
- CloudWatch, CloudTrail
- Ubuntu Linux (20.04)
- IAM Roles and Policies

## 📦 Infrastructure Components

| Component            | Details |
|---------------------|---------|
| **VPC**             | Custom VPC with public and private subnets |
| **Subnets**         | 2 Public, 2 Private (spread across AZs) |
| **NAT Gateway**     | For private subnet internet access |
| **Route Tables**    | Public and Private route tables |
| **Internet Gateway**| Attached to public subnets |
| **Security Groups** | Bastion, Web, Backend layer separation |
| **EC2 Instances**   | Bastion Host, Web Servers |
| **RDS**             | MySQL DB (in private subnet) |
| **Application Load Balancer (ALB)** | For traffic distribution to web servers |
| **CloudWatch Logs** | For application log monitoring |
| **Key Pair**        | For SSH access to Bastion Host |

---

## 🗂️ Project Structure

```bash
project-week8/
│
├── main.tf              # Main Terraform configuration file
├── variables.tf         # (Optional) Input variables definition
├── outputs.tf           # (Optional) Outputs for visibility
├── terraform.tfvars     # (Optional) Variable values
├── README.md            # Project documentation (you are here)
```

---

## 🌐 Skeleton Architecture Diagram

> A custom VPC with public and private subnets across two availability zones, with secure networking and layer-separated resources.

```
                   +---------------------+
                   |   Internet Gateway  |
                   +---------+-----------+
                             |
                   +---------v----------+
                   |      Public RT      |
                   +---------+----------+
                             |
        +--------+           |            +--------+
        | Subnet |<----------+----------->| Subnet |
        | 1a     |                        | 1b     |
        +--------+                        +--------+
        |  Bastion  |                    |  Web 2  |
        |  Web 1    |                    |         |
        +--------+                        +--------+
                             |
                  +----------v----------+
                  |     NAT Gateway     |
                  +----------+----------+
                             |
                  +----------v----------+
                  |     Private RT      |
                  +----------+----------+
                             |
       +--------+                         +--------+
       | Subnet |                         | Subnet |
       | 3a     |                         | 3b     |
       +--------+                         +--------+
       |   RDS   |                        | Future |
       |         |                        |  Use   |
       +--------+                         +--------+

```

---

## 📊 Architecture Diagram Image

![Architecture Diagram](images/diagram.png)

**The Architecture Design

🧱 [System Architecture Diagram on draw.io](https://bit.ly/3E5m3Tb)



## 🔐 Security Measures

- IAM user roles with least privilege access
- Security groups per layer (Load Balancer, App, DB)
- NACLs on subnets for extra protection
- Encrypted communication & backups

## 🔄 Auto Scaling & Load Balancing

- Launch Template based on custom AMI
- ASG spans multiple AZs with dynamic scaling
- Health checks via ALB
- ELB listeners for HTTP/HTTPS traffic

## 📈 Monitoring & Logging

- CloudWatch for metrics & alarms
- CloudTrail for API call history
- Logs stored in CloudWatch Logs group


## 👥 Team Roles

- **Architect:** VPC & architecture design
- **Engineer:** EC2, ALB, ASG setup
- **DB Admin:** RDS configuration
- **Security:** IAM, SG, ACL setup
- **Ops:** Monitoring & documentation


## 🚀 Deployment Steps

1. **Clone the repository**
```bash
git clone https://github.com/mangucletus/ShopEase-LTD-cloud-migration.git
cd ShopEase-LTD-cloud-migration
```

2. **Initialize Terraform**
```bash
terraform init
```

3. **(Optional) Review and set variables**
Edit `terraform.tfvars` or modify directly in `main.tf`.

4. **Plan the infrastructure**
```bash
terraform plan
```

5. **Apply to provision resources**
```bash
terraform apply
```

6. **Access the Bastion Host**
```bash
ssh -i ~/.ssh/your-key.pem ec2-user@<bastion-public-ip>
```

---


## 📝 Notes

- **Public AMI:** The example uses Amazon Linux 2 AMI (`ami-0c2b8ca1dad447f8a`). You may change it to your preferred region-specific image.
- **Database Credentials:** Hardcoded for demonstration. Replace with secure secret management.
- **Web Server Setup:** You can use user_data scripts or Ansible to configure web servers after provisioning.

---

## 📊 CloudWatch Monitoring

- A dedicated CloudWatch Log Group `/shopease/app` is created.
- Application logs should be pushed via the EC2 instances using the CloudWatch agent.

---

## 🧹 Cleanup

To destroy the entire infrastructure:
```bash
terraform destroy
```

---

## 👨‍💻 Author & Team

**Gen Cloud Consult**  
DevOps Engineers | AWS Practitioners | Cloud Architects

---

## 📄 License

This project is for educational and professional capstone purposes under the **AWS Cloud Migration** track. No commercial license applies.


## Project Report
🔗 [Project Report - Microsoft Word Document](https://bit.ly/42o8uGq)

