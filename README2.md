# 🚀 ShopEase LTD Cloud Infrastructure - Terraform Project

This project provisions a secure, scalable, and highly available AWS infrastructure for **ShopEase LTD**, an e-commerce platform. It uses **Terraform** to define infrastructure as code (IaC), enabling consistent, repeatable deployments and team collaboration.

---

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

## 🌐 Architecture Diagram

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

## 🛠️ Prerequisites

- [Terraform CLI](https://developer.hashicorp.com/terraform/downloads)
- AWS CLI configured (`aws configure`)
- AWS account with IAM access
- SSH key pair (public key for bastion host access)

---

## 🚀 Deployment Steps

1. **Clone the repository**
```bash
git clone https://github.com/your-org/shopease-infra.git
cd shopease-infra
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

## 🔐 Security Best Practices

- Use secrets manager or environment variables to store credentials.
- Restrict SSH access using IP whitelisting.
- Use encryption for RDS (add `storage_encrypted = true`).
- Enable monitoring with CloudWatch and alarms.

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
