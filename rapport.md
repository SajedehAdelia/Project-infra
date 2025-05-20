# Technical Report – DevOps Automation of an API

## Objective

The objective of this project is to set up a complete DevOps pipeline, enabling:
- Automatic provisioning of server infrastructure,
- Automated deployment of an API onto this infrastructure,
- Orchestration of the CI/CD process from code to production.

---

## Architecture

### 1. Terraform – Infrastructure Provisioning
- Creation of an EC2 instance on AWS.
- Configuration of networking and security groups to allow access to the API.
- Key files:
  - `main.tf`: defines the resources (VM, network),
  - `variables.tf`: contains configurable parameters (AMI, region, instance type),
  - `outputs.tf`: displays the public IP of the instance.

### 2. Ansible – Automated API Deployment
- Automatic installation of system and Python dependencies,
- Copying of API files to the virtual machine,
- Launch of the API in the background.

### 3. GitHub Actions – CI/CD Orchestration
- Automatically triggered on each push to the `main` branch,
- Steps:
  - Run `terraform init` and `terraform apply`,
  - Execute the Ansible playbook,
  - Final deployment and verification.

---

## Release Automation

A `release.sh` script is provided to:
- Increment the version according to SemVer (`major`, `minor`, `patch`),
- Generate a changelog,
- Create a Git tag and publish a release on GitHub.

---

## Technologies

| Tool             | Purpose                      |
|------------------|-------------------------------|
| Terraform        | Infrastructure provisioning   |
| Ansible          | Configuration and deployment  |
| GitHub Actions   | CI/CD automation              |
| Bash, Git        | Release scripting             |

---

## Results

- Reproducible and automated deployment process,
- Infrastructure version-controlled with Git,
- Reliable CI/CD with immediate feedback on failures.

---

## Future Improvements

- Add monitoring with Prometheus and Grafana,
- Integrate unit and integration testing,
- Implement automatic rollback in case of failure.

---

## Author

Adelia Fathipour
Computer scinece Student – Ynov
