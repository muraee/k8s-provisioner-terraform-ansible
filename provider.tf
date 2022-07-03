provider "google" {
  credentials = file(var.gcp_creds_file_path)

  project = var.project
  region  = var.region
  zone    = var.zone
}
