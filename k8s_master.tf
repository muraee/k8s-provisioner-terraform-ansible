resource "google_compute_instance" "k8s_cp_vm_instance" {
  name         = "k8s-cp"
  machine_type = "e2-standard-2"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
      type  = "pd-balanced"
      size  = 20
    }
  }

  network_interface {
    network = google_compute_network.k8s_vpc_network.name
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
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ${var.ssh_keys[0].user} -i '${self.network_interface.0.access_config.0.nat_ip},' --private-key ${var.ssh_keys[0].privatekeyPath} ./ansible/master.yaml"
  }
}

output "k8s_cp_ip_address" {
  value = google_compute_instance.k8s_cp_vm_instance.network_interface.0.access_config.0.nat_ip
}
