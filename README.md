Conversion Core Project

SQL Server · T-SQL · Docker · Python · Terraform · AWS

Educational and demonstration project only
No real client data, schemas, or proprietary logic are used.

Overview

The Conversion Core Project demonstrates a realistic, end-to-end data conversion pipeline that mirrors how conversion and platform engineering work is performed in professional environments.

The project intentionally evolves from pure T-SQL conversion logic into a cloud-ready, infrastructure-as-code–driven execution environment with durable artifacts, strong security boundaries, and operational discipline.

Core principles

SQL does the data work

Python orchestrates execution and reporting

Infrastructure is disposable, reproducible, and secure

Artifacts persist independently of compute

What This Project Demonstrates

Real-world T-SQL data conversion patterns

Safe, idempotent SQL script design

Python orchestration that controls SQL without replacing it

Dockerized SQL Server environments

Terraform-provisioned AWS infrastructure

Secure private networking (no public DB access)

Artifact persistence to S3

Strong secret-handling discipline

Operational awareness over shortcuts

Tech Stack

Data & Runtime

SQL Server 2022 (Developer Edition)

T-SQL

Python 3

Docker & Docker Compose

Cloud & Infrastructure

Terraform

AWS EC2

AWS VPC (public/private subnets)

AWS S3

AWS Systems Manager (SSM)

Tooling

Azure Data Studio

Git & GitHub

Databases

Client_Source_DB
Simulates legacy client data (intentionally messy).

Client_Template_DB
Simulates a company-owned target schema with strict constraints.

Project Phases
Phase 1 – Core Conversion (T-SQL)

This phase simulates a classic production data conversion using pure T-SQL.

Characteristics

Source data is loosely constrained

Target schema is strict

Conversion logic handles bad data

Scripts are safe to re-run (idempotent)

SQL Script Order

01_CreateDBs.sql
Drops and recreates source and template databases (dev only)

02_Source_Permits.sql
Creates legacy tables and inserts intentionally bad data

03_Template_Permit_Setup.sql
Creates target tables (Permit, Permit_Rejects)

04_Template_Permit_Load.sql
Loads source → template

Generates missing IDs

Routes invalid rows to rejects

Phase 2 – Dockerized SQL Server

SQL Server runs locally inside Docker to provide an isolated, disposable environment.

docker compose up -d
docker compose down

The entire environment can be destroyed and recreated at any time.

Phase 3 – Cloud Deployment (AWS)
Phase 3A – AWS SQL Server Runner

Terraform-provisioned AWS environment

Private EC2 instance

SQL Server running in Docker

No public IPs

Access via AWS Systems Manager (SSM)

Database access via SSM port forwarding

Phase 3B – Observability & Lifecycle

Disk sizing and boot reliability fixes

Clean teardown via terraform destroy

No residual cloud resources

Phase 4 – Python Orchestration Layer

Python is introduced as the automation layer, without replacing SQL.

Design Principle

SQL performs data operations.
Python controls execution, logging, and reporting.

What Python Does

Executes numbered SQL scripts in order

Handles admin vs transactional steps

Tracks execution timing and status

Stops the pipeline on failure

Generates structured artifacts:

step_results.csv

row_counts.csv

reject_reason_summary.csv

run_summary.json

Phase 5 – Infrastructure as Code & Artifact Persistence ✅

This phase formalizes the execution environment and artifact lifecycle using Infrastructure as Code (IaC).

Objectives

Repeatable infrastructure provisioning

Secure, private execution environment

Durable artifact storage

No secrets committed to Git

Architecture Overview

Region

us-east-1

Networking

Custom VPC

Public + private subnets

NAT Gateway for outbound access

No inbound access to compute

Compute

Private EC2 “runner”

No public IP

No SSH or RDP

Access via SSM only

Runtime

Docker

SQL Server 2022 container

Python orchestrator

Storage

S3 artifacts bucket

Environment-scoped paths:

s3://<artifacts-bucket>/runs/<env>/<run_id>/

Terraform Structure
terraform/
├── bootstrap/ # Remote state (S3 + DynamoDB)
├── envs/
│ └── dev/ # Environment wiring
├── modules/
│ ├── vpc/
│ ├── runner_ec2/
│ └── artifacts_s3/

Key Traits

Remote state

State locking

Modular design

No secrets in repo

Security Model

No inbound security group rules

No SSH keys

No public IPs

Access via SSM Session Manager

Secrets supplied via local terraform.tfvars

Example configs committed as terraform.tfvars.example

Artifact Persistence (New)

After a successful run:

Artifacts are written locally:

runs/<run_id>/

Artifacts are uploaded automatically to S3:

s3://<artifacts-bucket>/runs/<env>/<run_id>/

Artifacts include

step_results.csv

row_counts.csv

reject_reason_summary.csv

run_summary.json

Example successful upload:

☁️ Uploaded 4 artifacts to
s3://conversion-core-dev-183295427973-artifacts/runs/dev/2026-01-26_121923/

Verified End-to-End Flow

Terraform provisions infrastructure

SQL Server runs in Docker on private EC2

Python orchestrator executes conversion

Artifacts are generated locally

Artifacts are uploaded to S3 using IAM role credentials

No credentials or secrets are hardcoded

Phase 5 Status

Status: ✅ Complete

This phase establishes:

Enterprise-style infrastructure provisioning

Secure execution environments

Durable artifact storage

Proper secret-handling discipline

A strong foundation for automation
