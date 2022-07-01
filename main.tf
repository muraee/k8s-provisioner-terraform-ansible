terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.22.0"
    }
  }
}

provider "google" {
  credentials = file(var.gcp_creds_file_path)

  project = var.project
  region  = var.region
  zone    = var.zone
}

resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
}

resource "google_compute_instance" "vm_instance" {
  for_each = var.nodes

  name         = each.value.name
  machine_type = "e2-standard-2"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
      type  = "pd-balanced"
      size  = 20
    }
  }

  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
    }
  }

  metadata = {
    ssh-keys = join("\n", [for key in var.ssh_keys : "${key.user}:${key.publickey}"])
  }

  provisioner "remote-exec" {
    inline = ["sudo apt update", "sudo apt install python3 -y", "echo Done!"]

    connection {
      host        = self.network_interface.0.access_config.0.nat_ip
      type        = "ssh"
      user        = var.ssh_keys[0].user
      private_key = file(var.ssh_keys[0].privatekeyPath)
    }
  }

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ${var.ssh_keys[0].user} -i '${self.network_interface.0.access_config.0.nat_ip},' --private-key ${var.ssh_keys[0].privatekeyPath} ${each.value.playbook}"
  }
}

resource "google_compute_firewall" "allow_all" {
  name = "allow-all-firewall"

  allow {
    protocol = "tcp"
  }

  source_tags = []
  network     = google_compute_network.vpc_network.name
}

output "vm_instance_ip_addresses" {
  value = {
    for instance in google_compute_instance.vm_instance :
    instance.name => instance.network_interface.0.access_config.0.nat_ip
  }
}
