Conversion Core Project

SQL Server · T-SQL · Docker · Python · Terraform · AWS

Educational and demonstration project only.
No real client data, schemas, or proprietary logic are used.

This repository demonstrates a realistic, end-to-end data conversion pipeline, starting from raw T-SQL conversion logic and evolving into a cloud-ready, Python-orchestrated, observable system.

The project mirrors how conversion work is actually performed in professional environments:

SQL does the data work

Python orchestrates execution and reporting

Infrastructure is disposable, reproducible, and secure

What This Project Demonstrates

Real-world T-SQL data conversion patterns

Safe, idempotent SQL script design

Python orchestration that controls SQL without replacing it

Dockerized SQL Server environments

AWS infrastructure built and destroyed with Terraform

Secure, private cloud networking (no public DB access)

Operational hygiene (metrics, rejects, artifacts, cleanup)

Tech Stack

SQL Server 2022

T-SQL

Python 3

Docker & Docker Compose

Terraform

AWS (EC2, VPC, S3, CloudWatch, SSM)

Azure Data Studio

Git & GitHub

Databases

Client_Source_DB
Simulates legacy client data (intentionally messy).

Client_Template_DB
Simulates a company-owned target schema with strict requirements.

Phase 1 – Core Conversion (T-SQL)

This phase simulates a classic data conversion using pure T-SQL.

Key characteristics:

Source data is loosely constrained

Target schema is fixed and strict

Conversion logic handles bad data

Scripts are safe to re-run

SQL Script Run Order

01_CreateDBs.sql

Drops and recreates Source and Template databases

Intended for local/dev resets only

02_Source_Permits.sql

Creates dbo.Legacy_Permits

Inserts intentionally bad legacy data

03_Template_Permit_Setup.sql

Creates target tables (Permit, Permit_Rejects)

Setup-only script

04_Template_Permit_Load.sql

Loads Source → Template using INSERT INTO … SELECT

Generates PermitNumber when missing

Routes invalid rows to Permit_Rejects

Designed to be idempotent

Phase 2 – Dockerized SQL Server

SQL Server runs locally in Docker to provide an isolated, disposable environment.

Start SQL Server
docker compose up -d

Stop SQL Server
docker compose down

The environment can be destroyed and recreated at any time.

Phase 3A – AWS Deployment (EC2 + Docker SQL Server)
Infrastructure

Terraform-provisioned AWS environment:

Custom VPC with public + private subnets

NAT Gateway for outbound access

Amazon Linux EC2 in a private subnet

SQL Server running in Docker on EC2

S3 bucket for conversion artifacts

Security & Access

No public IPs on the database host

No SSH or RDP

Access via AWS Systems Manager Session Manager

Database access via SSM port forwarding (localhost:1433)

Execution

Phase 1 SQL scripts executed unchanged against AWS SQL Server

Artifacts exported and uploaded to S3

Results

Source rows: 6

Loaded permits: 2

Rejected rows: 4

Phase 3B – Observability & Lifecycle Management
Observability

CloudWatch Agent installed on EC2

Custom namespace: EPLConversion/EC2

Metrics:

CPU

Memory

Disk usage

CloudWatch alarms configured

Secure Operations

Private EC2 instance

Access exclusively via SSM

No inbound access rules

Teardown & Cost Control

Full teardown via terraform destroy

S3 versioning blockers resolved

force_destroy = true added for dev buckets

Zero residual cloud resources

Phase 4 – Python Orchestration Layer ⭐

This phase introduces Python as the automation layer, without replacing SQL.

Design Principle

SQL performs data operations.
Python controls execution, logging, and reporting.

What Python Does

Executes numbered SQL scripts in order

Handles admin vs transactional scripts

Tracks execution timing and row counts

Stops pipeline on failure

Generates run artifacts:

step_results.csv

row_counts.csv

reject_reason_summary.csv

Writes structured run metadata (run_summary.json)

Key Files
python/
├── db.py # SQL Server connection + execution helpers
├── run_conversion.py # Orchestrates the entire pipeline
├── reports.py # CSV report writers

Run the Full Pipeline
python -m python.run_conversion

Security

No secrets committed

All credentials sourced from environment variables

.env, Terraform state, and run artifacts are git-ignored

Project Status

Phase 1 – Core SQL Conversion ✅

Phase 2 – Dockerized Environment ✅

Phase 3A – AWS Deployment ✅

Phase 3B – Observability & Teardown ✅

Phase 4 – Python Orchestration ✅

Notes

This project is intentionally designed to resemble real conversion engineering work, not toy examples.
It emphasizes correctness, safety, and operational awareness over shortcuts.
