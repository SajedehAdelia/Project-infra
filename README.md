### 🔧 `api`

1. Open a terminal in the `api` directory.
2. Install dependencies:

   ```bash
   npm install
   ```
3. Start the API:

   ```bash
   npm start
   ```
4. Verify that the API is accessible at `http://0.0.0.0:3000` (or your local IP address).

#### Test Workflow Status:

![workflow](https://github.com/Projet-CI-CD/API/actions/workflows/ci.yml/badge.svg)

#### Release Workflow Status:

![workflow](https://github.com/Projet-CI-CD/API/actions/workflows/release.yml/badge.svg)

> ⚠️ **Note:** Terraform provisioning may fail in this demo context due to the debit card requirement. As a team decision, we chose to test Terraform deployment using a single bank card for our main API project. The Terraform workflow is expected to function correctly in that environment.
