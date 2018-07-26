provider "google" {
}

resource "google_project" "project" {
  name       = "${var.gcloud_project_name}"
  project_id = "${var.gcloud_project_id}"
}
