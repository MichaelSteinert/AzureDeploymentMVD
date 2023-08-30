# Azure Deployment of MVD

## Create Virtual Machine (VM) Environment

```bash
terraform init -upgrade
terraform plan -out main.tfplan
terraform apply main.tfplan
```

## Destroy VM Environment

```bash
terraform plan -destroy -out main.destroy.tfplan
terraform apply main.destroy.tfplan
```

## Save Private Key

- Private Key must be saved so that a Connection to the VM is possible.

```bash
touch id_rsa.pem
```

## Grant Permission to Private Key

- Owner of Private Key will have Read and Write Permissions, while the Group and others will have no Permissions for Private Key.

```bash
chmod 600 id_rsa.pem
```

## Connect to VM as Admin

- Connect to VM as User `mvdadmin` by using Private Key.

```bash
ssh -i ~/.ssh/id_rsa.pem mvdadmin@20.218.249.77
```

## Install Java and Docker

## Run Build Minimum Viable Dataspace (MVD)

```bash
./gradlew build -x test
./gradlew -DuseFsVault="true" :launchers:connector:shadowJar
./gradlew -DuseFsVault="true" :launchers:registrationservice:shadowJar
```

## Run MVD

```bash
export MVD_UI_PATH=../../DataDashboard
cd system-tests/
sudo docker compose --profile ui -f docker-compose.yml up --build
```

- When the following Error is displayed: `failed to solve: failed to read dockerfile: open /var/lib/docker/tmp/buildkit-mount123456789/Dockerfile: no such file or directory`, then the Setting of the `MVD_UI_PATH` Variable does not work
- The Solution is to set the UI Path manually to `../../DataDashboard` in the `docker-compose` File
