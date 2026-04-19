# DevOps for Teamatical — Demo Project

## Overview
This repository contains a demo implementation of a cloud infrastructure and CI/CD pipeline designed using DevOps best practices.

The project demonstrates the application of Infrastructure as Code (IaC), a controlled CI/CD workflow, and a security-oriented approach aligned with SOC 2 principles.

---

## Architecture
The project is based on a modular Azure infrastructure implemented using Bicep.

The initial version (v0.9) includes:
- Virtual Network (VNet)
- Subnets (web, database, gateway)
- Network Security Group (NSG)
- Public IP
- Application Gateway
- Network Interfaces (NIC)
- Virtual Machines
- Azure SQL (PaaS)

The architecture is designed to be extendable and serves as a baseline for further iterations.

## Architecture

<p align="center">
  <img src="arch.jpg" width="900">
</p>
<p align="center">
  <i>Figure 1: Infrastructure Architecture with Future Extensions</i>
</p>

---

## CI/CD Workflow
The deployment process is implemented using GitHub Actions and follows a controlled, approval-based workflow.

The main steps are:
1. Code is developed locally and submitted via Pull Request
2. Pull Request is reviewed and approved
3. PR validation pipeline is executed
4. Deployment validation is performed
5. Manual approval is required before deployment
6. Infrastructure is deployed to Azure

Infrastructure changes are applied only through CI, ensuring control and consistency.

## CI/CD Workflow

<p align="center">
  <img src="pipe.png" width="900">
</p>
<p align="center">
  <i>Figure 2: CI/CD Pipeline with Approval and Validation Stages</i>
</p>

---

## Security
The project follows a security-first approach:

- No secrets are stored in the repository
- Sensitive data is managed via GitHub Secrets
- Authentication between GitHub and Azure is implemented using OIDC (OpenID Connect)
- Access within Azure is controlled using RBAC and policies
- PR pipeline includes validation steps such as secret scanning and configuration checks

---

## Key Principles
- Infrastructure as Code (Bicep)
- CI-driven deployment (no manual changes)
- Controlled release process with approvals
- Validation before deployment (including what-if analysis)
- Protection against infrastructure drift
- Incremental delivery model (v0.9 → v1.0 → further extensions)

---

## Repository Structure

infra/
  modules/
    app_gateway.bicep
    network.bicep
    nic.bicep
    nsg.bicep
    public_ip.bicep
    sql.bicep
    vm.bicep
  main.bicep
  prod.parameters.json

.github/workflows/
  pr_check.yaml
  deploy.yaml

---

## Versions

### v0.9
Initial baseline implementation:
- Core infrastructure components
- Basic CI/CD pipeline
- Azure SQL (PaaS)

### v1.0 (planned)
- Observability stack (Azure Monitor, Log Analytics, Application Insights)
- Security improvements (WAF, Firewall, Key Vault, Defender)
- Autoscaling (VM Scale Sets)
- Azure DNS and CDN

### Future (vision)
- Azure Kubernetes Service (AKS)
- Serverless components (Azure Functions)
- Azure OpenAI integration
- Azure Data Factory

---

## Notes
This project represents a working MVP designed to demonstrate architectural thinking, implementation skills, and DevOps workflow design.

The implementation was completed within a limited time frame (approximately one working day). Further improvements and extensions can be implemented as next steps.
