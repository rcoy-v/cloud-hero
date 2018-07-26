provider "google" {
}

resource "google_project" "project" {
  name       = "${var.gcloud_project_name}"
  project_id = "${var.gcloud_project_id}"
}

// APIs

resource "google_project_service" "container-api" {
  project = "${google_project.project.project_id}"
  service = "container.googleapis.com"
}

resource "google_project_service" "compute-api" {
  project = "${google_project.project.project_id}"
  service = "compute.googleapis.com"
}

resource "google_project_service" "logging-api" {
  project = "${google_project.project.project_id}"
  service = "logging.googleapis.com"
}

resource "google_project_service" "monitoring-api" {
  project = "${google_project.project.project_id}"
  service = "monitoring.googleapis.com"
}

// Service Account

resource "google_service_account" "gke" {
  account_id   = "gke-service-account"
  display_name = "gke-service-account"
  project      = "${google_project.project.project_id}"
}

resource "google_project_iam_member" "gke-editor" {
  project = "${google_project.project.project_id}"
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.gke.email}"
}

resource "google_container_cluster" "cluster" {
  project            = "${var.gcloud_project_id}"
  name               = "gke"
  zone               = "us-central1-f"
  initial_node_count = "2"
  logging_service    = "logging.googleapis.com"
  monitoring_service = "monitoring.googleapis.com"
  min_master_version = "1.10.4-gke.2"
  node_version       = "1.10.4-gke.2"

  enable_legacy_abac = false

  node_config {
    machine_type    = "n1-standard-2"
    disk_size_gb    = 100
    image_type      = "COS"
    service_account = "${google_service_account.gke.email}"
    oauth_scopes    = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/trace.append",
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/monitoring"
    ]
  }

  depends_on         = [
    "google_project_service.container-api",
    "google_project_service.logging-api",
    "google_project_service.monitoring-api"
  ]
}
