## Infrastructure Overview for High-Availability Web Application Deployment

This Terraform-based infrastructure deploys a high-availability, secure, and fault-tolerant architecture on AWS. It is designed to host a scalable frontend application with backend services, using Amazon S3, CloudFront, and EKS. This setup supports automatic failover, origin access identities, and redundancy across multiple availability zones (AZs) for enhanced reliability.

## Architecture Diagram

## Architecture Components

Network Infrastructure (VPC)
VPC (Virtual Private Cloud):

- A VPC with both public and private subnets across multiple AZs.
  Public Subnets: Used to host the NAT gateways and ALB (Application Load Balancer) for managing external traffic securely.
  Private Subnets: Host the EKS cluster and RDS, providing private network access for backend services.
  Internet Gateway:

- Provides internet access to resources in the public subnet.
  NAT Gateway:

- A NAT Gateway is deployed in each public subnet, allowing instances in the private subnets to access the internet securely.
  \*Route Tables:

- Public Route Table: Routes internet-bound traffic through the Internet Gateway.
- Private Route Table: Routes internet-bound traffic through the NAT Gateway for private subnet resources.
- Network ACLs:

- Configured to provide ingress and egress controls on public and private subnets.
  Frontend Infrastructure
  Amazon S3 with Cross-Region Replication (CRR):

- Two S3 buckets are configured for the frontend and landing pages, with a primary and failover bucket for each.
- Cross-region replication (CRR) ensures data redundancy by replicating objects from the primary to the failover bucket.
  Amazon CloudFront with Origin Access Identity (OAI):

- CloudFront distributions are created with origin access identities (OAI) to securely serve content from S3.
- Origin Group: Configured with primary and failover S3 origins to automatically switch if the primary origin becomes unavailable.
- SSL certificates (ACM) are used to secure HTTPS access to CloudFront distributions.
- AWS ACM (SSL Certificates):

ACM certificates are issued for both frontend and landing domains to secure CloudFront distributions.

- Amazon Route 53:

Manages DNS records for api.deeplink.in and other frontend domains.
Routes traffic to the CloudFront distributions and ALB as per host-based routing rules.
Backend Infrastructure

- EKS (Elastic Kubernetes Service):

- Deployed within private subnets, with worker nodes managed by autoscaling groups.
  Provides a highly available, scalable environment for running containerized backend services.
  Integrated with IAM for Service Accounts (IRSA) to allow pods to securely access AWS services.
- RDS (Relational Database Service):

RDS instances are deployed within private subnets, ensuring database access is restricted and secure.
ALB (Application Load Balancer):

- Deployed in the public subnet to route HTTPS traffic to backend services in EKS.
  Configured with target groups and health checks to ensure high availability.
  IAM Roles and Policies:

- Configured IAM roles and policies to allow secure access to AWS services.
- IRSA is used to securely grant EKS pods access to required services like Secrets Manager and CloudWatch.
- Infrastructure as Code (Terraform)
- VPC and Networking
  aws_vpc: Configures the VPC with DNS support.
  aws_internet_gateway: Provides internet access for public resources.
  aws_subnet: Defines public and private subnets across multiple AZs.
  aws_nat_gateway: Ensures secure internet access for private subnet resources.
  aws_route_table and aws_route_table_association: Configures routing for public and private subnets.
  aws_network_acl: Defines Network ACLs for added security on subnets.
  Storage and Replication
  aws_s3_bucket and aws_s3_bucket_replication_configuration: Sets up primary and failover S3 buckets with cross-region replication (CRR).
  aws_iam_role for S3 replication permissions.
  Content Delivery and Security
  aws_cloudfront_origin_access_identity: Restricts S3 bucket access to CloudFront.
  aws_cloudfront_distribution: Configures CloudFront with origin groups for primary and failover buckets, SSL/TLS security, and caching behavior.
  aws_acm_certificate: Issues certificates for secure HTTPS access on CloudFront.
  Application Load Balancing
  aws_lb, aws_lb_listener, and aws_lb_target_group: Sets up an Application Load Balancer for backend services with target groups and health checks.
  aws_route53_record: Creates DNS records in Route 53 for the frontend and backend services.
  Autoscaling and EKS Integration
  aws_autoscaling_attachment: Attaches the ALB target group to EKS worker node autoscaling groups.
  aws_security_group for ALB ingress traffic.
  Prerequisites
  AWS CLI installed and configured.
  Terraform installed.
  IAM permissions to create resources in AWS.
  Usage
  Initialize Terraform:

### Security Considerations

- IAM roles and policies are defined to grant least privilege access.
- S3 buckets are private and accessible only via CloudFront using Origin Access Identity (OAI).
- SSL/TLS is enforced for frontend and backend traffic using ACM certificates.
- Security Groups and Network ACLs restrict access to essential ports.
- Monitoring and Logging
- AWS CloudWatch can be integrated with EKS to monitor logs and metrics for backend services.
- CloudFront provides logging for web access patterns and performance monitoring.
  Notes
* Update DNS records in Route 53 as needed to point to the CloudFront distribution or ALB for your desired domains.
- Enable cross-region replication carefully, as it may incur additional charges.

* In this setup, Network ACL (NACL) rules are applied at the subnet level to provide additional security by controlling traffic in and out of both public and private subnets in the VPC. NACLs work as stateless firewalls and are commonly used to add an extra layer of protection alongside Security Groups in AWS.

* NACL Rules Overview
Public NACL Rules:

* Associated with public subnets, where resources like NAT Gateways and Application Load Balancers (ALB) reside.
Allows inbound and outbound internet traffic as required for public-facing services.
Private NACL Rules:

* Associated with private subnets, where internal resources like EKS nodes and RDS instances reside.
Controls traffic within the VPC and restricts direct access from the internet.
Example Configuration for Public NACL
* Inbound Rules:

HTTP (Port 80): Allows incoming HTTP traffic from any IP (0.0.0.0/0). This rule is optional if only HTTPS traffic is preferred.
HTTPS (Port 443): Allows incoming HTTPS traffic from any IP (0.0.0.0/0) for secure access to ALB.
SSH (Port 22): Restricted to trusted IP ranges (e.g., your office IP) to allow SSH access to bastion hosts if needed.
Custom Ports for ALB Health Checks: Allows health checks from ALB to EKS worker nodes on specific ports (e.g., 31336).
* Outbound Rules:

All Traffic: Allows all outbound traffic (0.0.0.0/0) so public subnets can send responses back to clients or access external resources if needed.

AWS Infrastructure Setup for High-Availability Web Application
This project sets up a secure and highly available infrastructure on AWS using Terraform. It is designed to host both frontend and backend services with redundancy, automatic failover, and scaling capabilities. The infrastructure includes a VPC with public and private subnets, an EKS cluster in private subnets, a highly available RDS database, and CloudFront distributions backed by S3 for frontend content delivery.

Step 1: Clone the Repository

git clone https://github.com/your-repo/aws-infrastructure
cd Infrastructure/Backend
Step 2: Initialize Terraform
`terraform init`
Step 3: Configure Variables
default input variables used.

cidr_range
supported_azs
primary_bucket_name_frontend
failover_bucket_name_frontend
primary_bucket_name_landing
failover_bucket_name_landing
frontend_cert (ACM Certificate ARN for frontend domain)
landing_cert (ACM Certificate ARN for landing page domain)
route53_zone_id (Route 53 hosted zone ID)
Step 4: Review and Apply the Plan

terraform plan
terraform apply
Step 5: Verification
EKS Cluster: Use kubectl to verify EKS cluster and node group health.
CloudFront Distributions: Access the CloudFront URLs to confirm frontend availability.
RDS Database: Connect to RDS from within the VPC to confirm database access.
Step 6: Clean Up Resources
To avoid charges, clean up resources:

`terraform destroy`
Key Resources
Network (VPC)
VPC: Main VPC with DNS support.
Subnets: Public and private subnets across multiple AZs.
Internet Gateway: Provides internet access for public subnet resources.
NAT Gateway: Allows private subnets to access the internet securely.
Network ACLs: Configures public and private subnet traffic rules.
Storage and Replication
S3 Buckets: Primary and failover buckets for frontend and landing content.
Replication Configuration: Cross-region replication (CRR) for S3 buckets.
Content Delivery (CloudFront)
CloudFront Distributions: Distributions for frontend and landing pages with Origin Access Identity (OAI).
SSL Certificates: ACM Certificates for HTTPS connections.
Load Balancing
Application Load Balancer (ALB): Handles HTTPS traffic for backend services.
Route 53 Records: DNS configuration for frontend and backend services.
Autoscaling and Access Control
EKS Autoscaling: Autoscaling groups for EKS worker nodes.
IAM Roles and Policies: Secure access control for AWS services and IRSA for EKS.
Security Considerations
IAM Roles and Policies: Granular permissions to allow least privilege access.
S3 Bucket Policies: Bucket access is restricted to CloudFront via Origin Access Identity (OAI).
SSL/TLS: HTTPS enabled for all frontend and backend traffic with ACM certificates.
Network ACLs and Security Groups: Restrict access to only required ports and protocols.
Monitoring and Logging
Integrate AWS CloudWatch to monitor logs and metrics for both EKS and CloudFront distributions. This setup allows real-time monitoring of application health, performance, and access patterns.

## These are my kubernetes objects created for my application and utilities:

Kubernetes Setup for Scalable Deep Linking Application
This setup defines Kubernetes objects to deploy a highly available and scalable application for generating deep links or short URLs. The infrastructure includes autoscaling, resource limits, monitoring, and logging. Additionally, it integrates external services like RDS and manages secrets securely.

Kubernetes Resources

1. Application Deployment
   Deployment: Manages the lifecycle of the application pods that generate deep links and short URLs.
   Horizontal Pod Autoscaling (HPA): Automatically scales the application pods based on CPU and memory usage.
   Vertical Pod Autoscaling (VPA): Provides resource recommendations for CPU and memory based on actual usage.
2. Autoscaling
   Horizontal Pod Autoscaler (HPA): Scales the application pods based on defined CPU and memory thresholds.
   Vertical Pod Autoscaler (VPA): Provides recommendations for the pods to adjust resource requests dynamically.
3. Resource Management
   LimitRange: Sets minimum and maximum resource requests and limits in the production namespace.
   ResourceQuota: Enforces quotas on the number of resources in the namespace.
4. Pod Disruption Budget (PDB)
   Ensures a minimum number of available pods during disruptions or maintenance events.
5. Database Connection
   External Service: Connects the application to an external RDS database.
6. Ingress for Routing
   Configures Ingress to route traffic to the application based on host.
7. Cluster Autoscaler
   Automatically adjusts the number of nodes based on pod demand, scaling up when there’s insufficient capacity and down when resources are underutilized.
8. External Secret Management
   External Secret with External Secrets Operator (ESO): Securely pulls secrets from AWS Secrets Manager and injects them into Kubernetes as secrets.
9. Logging with ELK (Elasticsearch, Logstash, Kibana)
   Centralized logging setup using ELK stack. Kibana provides a dashboard for visualizing logs from application containers.
10. Monitoring with Prometheus and Grafana
    Prometheus: Collects metrics from Kubernetes resources and application services.
    Grafana: Provides visual dashboards to monitor metrics and alerts.
