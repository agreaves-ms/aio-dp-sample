# Azure IoT Operations Data Processor Sample

This repo will walkthrough deploying a workload and setting up AIO Data Processor for manipulating and sending data to
the cloud.

Refer
to [azure-samples/azure-edge-extensions-aio-iac-terraform](https://github.com/azure-samples/azure-edge-extensions-aio-iac-terraform)
for instructions on how to get an AIO environment installed using Terraform.

## Getting Started

### Prerequisites

- (Optionally for Windows) [WSL](https://learn.microsoft.com/windows/wsl/install) installed and setup.
- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) available on the command line where this will be
  deployed.
- [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) available on the command
  line where this will be deployed.
- [Docker](https://docs.docker.com/engine/install/) available on the command line.
- (Optional) Owner access to a Subscription to deploy the infrastructure.
    - (Or) Owner access to a Resource Group with an existing cluster configured and connected to Azure Arc.
- [azure-samples/azure-edge-extensions-aio-iac-terraform](https://github.com/azure-samples/azure-edge-extensions-aio-iac-terraform)
  installed and deployed

### Quickstart

### Login and Start Mqttui

This will first log in to the Azure tenant where your Azure Arc cluster is deployed. It will then setup an Azure Arc
Proxy and connect to a Pod running your cluster to run *mqttui*.

1. Log in to the AZ CLI:
    ```shell
    az login --tenant <tenant>.onmicrosoft.com
    ```
    - Make sure your subscription is the one that you would like to use: `az account show`.
    - Change to the subscription that you would like to use if needed:
      ```shell
      az account set -s <subscription-id>
      ```
2. Start the Azure Arc proxy on your local machine to access the Kuberenetes cluster:
    ```shell
    az connectedk8s proxy -g rg-<name> -n arc-<name>
    ```
3. Exec into the mqtt-client Kubernetes Pod that was deployed from
   the [azure-samples/azure-edge-extensions-aio-iac-terraform](https://github.com/azure-samples/azure-edge-extensions-aio-iac-terraform)
   repo.
    ```shell
    kubectl exec -it deployments/mqtt-client -c mqtt-client -n aio -- sh
    ```
4. Run `mqttui` from this new exec'd console running in your Kubernetes Pod.
    ```shell
    mqttui -b mqtts://aio-mq-dmqtt-frontend:8883 -u '$sat' --password $(cat /var/run/secrets/tokens/mq-sat) --insecure
    ```

#### Deploy Infrastructure

1. Add a `root-<unique-name>.tfvars` file to the root of the [deploy](deploy) directory that contains the following (
   refer to [deploy/sample-aio.general.tfvars.example](deploy/sample-aio.general.tfvars.example) for an example):
    ```hcl
    // <project-root>/deploy/root-<unique-name>.tfvars

    name = "<unique-name>"
    location = "<location>"
    ```
2. From the [deploy/1-infra](deploy/1-infra) directory execute the following (the `<unique-name>.auto.tfvars` created
   earlier will automatically be applied):
    ```shell
    terraform init
    terraform apply -var-file="../root-<unique-name>.tfvars"
    ```
    - This will setup the Azure cloud resources needed for this repo.
    - This step will also output a `acr-pull-secret.sh` to a new [out](out) directory.
3. Open the [out/acr-pull-secret.sh](out/acr-pull-secret.sh) that was created from the previous step, copy its contents
   and run them on the command line.
    ```shell
    eval "$(./out/acr-pull-secret.sh)"
    ```
    - This will add a new Secret to your cluster that contains the Service Principal with AcrPull permissions which will
      be used by your Kubernetes cluster to pull images from your new ACR to your cluster.

#### Build and Push Workload to ACR

1. Log in to your new ACR, the previous step removed any hyphens from your `name` variable so be sure to remove them
   when you log in:
    ```shell
    az acr login --name acr<name with no hyphens>
    ```
2. Build and push the [MqttSink](src/MqttSink) that's in this project.
    ```shell
    docker buildx build --platform linux/amd64 -t acr<name with no hyphens>.azurecr.io/mqttsink:0.0.1 --push -f src/MqttSink/Dockerfile .
    ```

#### Deploy Dapr into Cluster

This will deploy the Dapr Helm chart using the AIO Orchestrator. It will also install
the [Dapr PubSub and StateStore Pluggable components](https://learn.microsoft.com/azure/iot-operations/develop/howto-develop-dapr-apps#register-mqs-pluggable-components).

1. Repeat the same `terraform` commands for the [deploy/2-aio-dapr](deploy/2-aio-dapr) directory:
    ```shell
    terraform init
    terraform apply -var-file="../root-<unique-name>.tfvars"
    ```

#### Deploy the Workload into Cluster

This will deploy the new workload that was built and pushed to ACR using the AIO Orchestrator. It will be deployed with
Dapr side cars which will allow the MqttSink to subscribe and publish to topics on the AIO MQ broker.

1. Add a `<unique-name>.auto.tfvars` to the [deploy/3-aio-mqtt-sink](deploy/3-aio-mqtt-sink) directory that contains the
   following variables (refer to
   the [deploy/3-aio-mqtt-sink/sample-aio.auto.tfvars.example](deploy/3-aio-mqtt-sink/sample-aio.auto.tfvars.example)
   for an example):
    ```hcl
    // <project-root>/deploy/3-aio-mqtt-sink/<unique-name>.auto.tfvars

    mqtt_sink_version             = "0.0.1"
    ```
2. Repeat the same `terraform` commands for the [deploy/3-aio-mqtt-sink](deploy/3-aio-mqtt-sink) directory:
    ```shell
    terraform init
    terraform apply -var-file="../root-<unique-name>.tfvars"
    ```
