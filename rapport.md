# Rapport du Projet DevOps : Infrastructure GCP, API et Pipeline CI/CD

---

## 1. Introduction

Ce dépôt contient la configuration complète pour la mise en place de l’infrastructure cloud, la configuration des serveurs, le déploiement de l’API et l’automatisation via un pipeline CI/CD.  
Le projet utilise Google Cloud Platform (GCP) comme fournisseur de cloud, Terraform pour le provisioning, Ansible pour la configuration, et un pipeline CI/CD (à intégrer selon l’outil choisi).

---

## 2. Architecture Infrastructure et choix des providers

- **Provider Cloud :** Google Cloud Platform (GCP)  
  Nous avons choisi GCP pour sa robustesse, son offre complète et son intégration aisée avec Terraform.

- **Réseau :**  
  Création d’un réseau VPC dédié `api-network` pour isoler les ressources.

- **Sécurité :**  
  Firewall autorisant uniquement le trafic SSH (port 22) et vers l’API (port 3000).

- **Machine virtuelle :**  
  Une instance VM Ubuntu 22.04 LTS de type `e2-medium` déployée dans la zone configurée (variable `zone`).

---

## 3. Fonctionnement de la configuration Terraform et du playbook Ansible

### Terraform (`infra/`)

- Initialise et configure le provider GCP avec les variables suivantes :  
  - `gcp_credentials` (fichier JSON ou variable d’environnement)  
  - `project_id`, `region`, `zone`

- Provisionne les ressources :  
  - Un réseau VPC `api-network`  
  - Une règle firewall `allow-ssh-http` autorisant le trafic TCP sur les ports 22 (SSH) et 3000 (API) depuis n’importe quelle source  
  - Une VM Ubuntu 22.04 LTS avec accès public via adresse IP externe

- Injecte la clé SSH publique via le metadata pour permettre la connexion sécurisée.

### Ansible (`ansible/`)

- Inventaire statique ou dynamique listant la VM dans le groupe `api`.

- Playbook `deploy-api.yml` qui :  
  - Installe Docker Engine et Docker Compose sur la VM Ubuntu  
  - Active et démarre le service Docker  
  - Clone le dépôt Git de l’API dans `/opt/api`  
  - Lance l’application via `docker compose up -d --build` dans ce répertoire

Cette configuration garantit que la VM soit prête à exécuter l’API dans un environnement Docker isolé.

---

## 4. Déroulé du pipeline CI/CD

Le pipeline CI/CD s’appuie sur la gestion Git et un outil d’intégration continue (GitHub Actions, GitLab CI, Jenkins, etc.) avec les étapes suivantes :

1. **Tests unitaires et build** : Compilation et vérification de l’API (dans `api/`).

2. **Analyse statique** : Linting et contrôle qualité.

3. **Build de l’image Docker** : Construction de l’image Docker de l’API.

4. **Push vers un registre** : Envoi de l’image dans un registre Docker (Docker Hub, GCR).

5. **Provisioning infra avec Terraform** : Application des modifications d’infrastructure si nécessaire (`terraform apply`).

6. **Déploiement via Ansible** : Exécution du playbook Ansible pour mettre à jour le serveur avec la nouvelle version.

7. **Tests d’intégration** (optionnel) : Vérification du bon fonctionnement post-déploiement.

### Exemple de fichier pipeline (à adapter selon l’outil utilisé)

```yaml
name: Provision & Déploiement API

on:
  push:
    branches:
      - main

jobs:
  terraform:
    name: Provisionner l'infra GCP
    runs-on: ubuntu-latest

    steps:
      - name: Cloner le dépôt
        uses: actions/checkout@v3

      - name: Installer Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.6.6

      - name: Créer credentials.json depuis le secret base64
        run: |
          echo "${{ secrets.GCP_CREDENTIALS }}" | base64 -d > ${{ github.workspace }}/infra/credentials.json

      - name: Plan Terraform
        working-directory: infra
        run: |
          terraform init
          terraform plan \
            -var="gcp_credentials=${{ github.workspace }}/infra/credentials.json" \
            -var="ssh_public_key=${{ secrets.SSH_PUBLIC_KEY }}" \
            -var-file="terraform.tfvars"

      - name: Appliquer Terraform
        working-directory: infra
        run: |
          terraform apply -auto-approve \
            -var="gcp_credentials=${{ github.workspace }}/infra/credentials.json" \
            -var="ssh_public_key=${{ secrets.SSH_PUBLIC_KEY }}" \
            -var-file="terraform.tfvars"

      - name: Générer inventory.ini pour Ansible
        working-directory: infra
        run: |
          IP=$(terraform output -raw vm_external_ip)
          echo "[api]" > ../ansible/inventory.ini
          echo "$IP ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa" >> ../ansible/inventory.ini

  ansible:
    name: Déployer l'API avec Ansible
    runs-on: ubuntu-latest
    needs: terraform

    steps:
      - name: Cloner le dépôt
        uses: actions/checkout@v3

      - name: Installer Ansible et SSH client
        run: |
          sudo apt update
          sudo apt install -y ansible openssh-client

      - name: Ajouter la clé SSH privée
        run: |
          mkdir -p ~/.ssh
          echo "${{ secrets.ANSIBLE_SSH_PRIVATE_KEY }}" > ~/.ssh/id_rsa
          chmod 600 ~/.ssh/id_rsa

      - name: Exécuter le playbook Ansible
        run: |
          ansible-playbook -i ansible/inventory.ini ansible/deploy.yml --ssh-extra-args="-o StrictHostKeyChecking=no"
```

---

## 5. Logs et captures d’écran

Pipeline :
![image](https://github.com/user-attachments/assets/8f7ab661-b9a2-48f4-b7cd-b3dbff324b02)

Infra (GCP) :
![image](https://github.com/user-attachments/assets/937e739c-2eac-4b6c-be08-7ff8d21a5245)

Ansible :
![image](https://github.com/user-attachments/assets/1f8fb158-f52f-4e3a-9646-062b66fda520)

---

## 6. Conclusion

L’infrastructure est entièrement gérée via Terraform sur GCP, garantissant un environnement cohérent et facile à reproduire.  
La configuration Ansible permet un déploiement automatisé et fiable de l’API avec Docker.  
Le pipeline CI/CD orchestre l’ensemble, assurant intégration et livraison continue sans interruption.  

Ce système facilite la maintenance et prépare l’application à évoluer facilement.
