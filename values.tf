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


variable "worker_nodes_count" {
  type =  number
  default = 2
}
