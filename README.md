# Provision Kubernetes Cluster on the Cloud using Terrafrom and Ansible

## Prerequisites

- [Google Cloud Platform account](https://console.cloud.google.com/freetrial/)
- [Terraform](https://www.terraform.io/)
- Python 3
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)

## Getting started

### GCP service account

Terraform requires credentrials to autheniticate to GCP in order to provision the infrastructure. To provide those credentials you need to [create a service account](https://console.cloud.google.com/apis/credentials/serviceaccountkey) and save it to a file on your machine.

You can read more about service account keys in [Google's documentation](https://cloud.google.com/iam/docs/creating-managing-service-account-keys).

### Configuration

There are some required variables that Terrafrom needs:
- `gcp_creds_file_path`: The path to your GCP service account key file, that will be used for authentication.
- `project`: ID of the GCP project where the instances will be created.
- `ssh_keys`: A list of sshKeys to be attached to each VM instance.

Simply create a variables file named `terraform.tfvars`, which will be autmoatically imported by Terrafrom:

```tf
ssh_keys = [{
  privatekeyPath = "~/.ssh/id_ed25519"     // used by Ansible
  publickey      = "ssh-ed25519 AAAAC3N...."
  user           = "Max"
}]

gcp_creds_file_path = "~/gcp-credentials-key.json"
project = "my-project-id"
```

You can also override the following optional veriables in your variables file:
- `region`: GCP region | default: `europe-west1`
- `zone`: GCP Avaialbity zone, must be in the defined above region | default: `europe-west1-b`
- `worker_nodes_count`: Number of kubernetes worker nodes | default: `2`

See [`terraform.tfvars.example`](./terraform.tfvars.example) for a full example.

## Provisioning the cluster

```bash
terrafrom plan
```
To preview all the changes that Terrafrom will be performing.

```bash
terrafrom apply
```
This will execute the plan and provision your Kubernetes cluster. Ansible playbooks will be executed automatically by Terrafrom.

### Accessing the cluster

`terraform apply` will output the ip addresses of the control plane and worker nodes once it has finished. You can also run `terrafrom output` to display the same information.

Simply `ssh` into the control plane and start playing with your Cluster.
```bash
ssh user@<k8s-cp-IP>
```

> `kubectl` is already configured for the first user defined in `ssh_keys`
