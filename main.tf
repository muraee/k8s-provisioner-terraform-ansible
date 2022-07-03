resource "google_compute_network" "k8s_vpc_network" {
  name = "k8s-vpc"
}

resource "google_compute_firewall" "allow_all" {
  name = "allow-all-firewall"

  allow {
    protocol = "all"
  }

  source_tags = []
  network     = google_compute_network.k8s_vpc_network.name
}