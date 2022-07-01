variable "ssh_keys" {
  type = list(object({
    privatekeyPath = string
    publickey = string
    user      = string
  }))
}

variable "gcp_creds_file_path" {
  type = string
}

variable "project" {
  type = string
}

variable "region" {
  default = "europe-west1"
}

variable "zone" {
  default = "europe-west1-b"
}

variable "nodes" {
  type = map(any)
  default = {
    control-plane = {
      name = "k8s-cp"
      playbook = "./ansible/master.yaml"
    },
    worker = {
      name = "k8s-worker"
      playbook = "./ansible/worker.yaml"
    },
    worker2 = {
      name = "k8s-worker-2"
      playbook = "./ansible/worker.yaml"
    }
  }
}
