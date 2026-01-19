# Conversion Core Project (SQL Server + T-SQL)

This project is for **educational and demonstration purposes only**.  
No real client data, schemas, or proprietary logic are used.

---

## Phase 1 – Core Conversion (T-SQL) ******************\*\*******************\*\*******************\*\*******************\*\*\*******************\*\*******************\*\*******************\*\*******************

This project simulates a real-world **data conversion** where legacy client data is loaded into a fixed target schema using **T-SQL** and `INSERT INTO ... SELECT` patterns.

It mirrors common Conversion Engineer workflows:

- Source data is messy and loosely constrained
- Template schema is standardized and strict
- Conversion logic handles basic data issues
- Load scripts are safe to re-run (idempotent)

---

## Tech Stack

- **SQL Server 2022**
- **T-SQL**
- **Docker**
- **Azure Data Studio** (or VS Code)
- **Git & GitHub**

---

## Databases

- `Client_Source_DB`  
  Simulates client legacy data (messy by design).

- `Client_Template_DB`  
  Simulates a company-owned target schema with strict requirements.

---

## Scripts and Run Order

Run these scripts **in order**:

1. **01_CreateDBs.sql**

   - Creates `Client_Source_DB` and `Client_Template_DB`
   - Drops existing databases first to allow clean local resets

2. **02_Source_Permits.sql**

   - Creates `dbo.Legacy_Permits` in `Client_Source_DB`
   - Inserts sample legacy data including bad data (NULL and blank PermitNo)

3. **03_Template_Permit_Setup.sql**

   - Creates `dbo.Permit` in `Client_Template_DB`
   - Setup-only script (run once per environment reset)

4. **04_Template_Permit_Load.sql**
   - Loads data from Source → Template using `INSERT INTO ... SELECT`
   - Handles missing PermitNo by generating:
     - `00-<ApplicantName>` or `00-UNKNOWN`
   - Designed to be safely re-run
   - Includes validation queries (row counts and data review)

---

## Docker SQL Server (Local Environment)

SQL Server runs locally in Docker to provide an isolated development environment that does not depend on a host-installed database engine.

The environment is intentionally disposable and can be recreated at any time using the provided scripts.

---

## Phase 2 – Docker Compose ******************\*\*\*\*******************\*\*******************\*\*\*\*******************\*******************\*\*\*\*******************\*\*******************\*\*\*\*******************

The SQL Server environment is defined using **Docker Compose**, replacing the one-off `docker run` approach used during initial setup.

Docker Compose provides a **declarative and reproducible** environment definition. (Reference `.yml` file)

### Start SQL Server

```
docker compose up -d
```

### Stop SQL Server

```
docker compose down
```

## Phase 3a - AWS Deployment (Linux EC2 + Docker SQL Server) **************\*\***************\*\*\*\***************\*\***************\*\*\***************\*\***************\*\*\*\***************\*\***************

### Infrastructure

- Provisioned AWS infrastructure using Terraform:
  - Custom VPC with public and private subnets
  - Internet Gateway and NAT Gateway for private outbound access
- Deployed an Amazon Linux EC2 instance in a private subnet
- Installed Docker and ran SQL Server 2019 in a container
- Configured IAM role and instance profile for Systems Manager access
- Created an S3 bucket for conversion run artifacts

### Security & Access

- No public IP addresses on database host
- No inbound SSH or RDP access
- Secure access via AWS Systems Manager Session Manager
- Database access through SSM port forwarding (`localhost:1433`)
- Client connectivity using Azure Data Studio (macOS)

### Execution

- Infrastructure provisioned with Terraform
- Secure port forwarding session established from local machine
- Phase 1 SQL scripts executed unchanged against AWS-hosted SQL Server
- Conversion results exported and uploaded to S3

### Results

- Source rows: **6**
- Loaded permits: **2**
- Rejected rows: **4**

### Artifacts

- Runtime artifacts generated and stored in Amazon S3:
  - `row_counts.csv`
  - `reject_reason_summary.csv`
- Artifacts are intentionally excluded from source control

## Phase 3B – Observability & Lifecycle Management (CloudWatch + Cleanup) **************\*\***************\*\*\*\***************\*\***************\*\*\*********\*\*********\*********\*\*********

Goal

Add production-style monitoring and demonstrate safe infrastructure teardown.

Observability

Installed and configured the Amazon CloudWatch Agent

Published host-level metrics to a custom namespace:
EPLConversion/EC2

CPU utilization

Memory utilization

Disk usage

Attached least-privilege IAM permissions (CloudWatchAgentServerPolicy)

Created CloudWatch alarms for:

High CPU utilization

High memory utilization

High disk usage (root volume)

Secure Operations

EC2 instance remained private with no inbound access

Access performed exclusively via AWS Systems Manager Session Manager

Database connectivity maintained through SSM port forwarding

Infrastructure Teardown & Cost Control

Demonstrated safe teardown of all AWS resources using terraform destroy

Identified and resolved S3 versioning blockers during destroy

Programmatically deleted S3 object versions when required

Added force_destroy = true to dev S3 buckets to prevent future teardown issues

All AWS resources removed successfully, ensuring no ongoing cloud costs

Key Skills Demonstrated

SQL Server data conversion patterns

Idempotent T-SQL design

Dockerized database environments

Terraform Infrastructure as Code

Secure AWS networking (VPC, NAT, private subnets)

IAM least-privilege policies

AWS Systems Manager (SSM)

CloudWatch metrics and alarms

S3 artifact management

Infrastructure lifecycle management and cost control

Project Status

Phase 1 – Core SQL Conversion ✅

Phase 2 – Dockerized Environment ✅

Phase 3A – AWS Deployment ✅

Phase 3B – Observability & Teardown ✅
