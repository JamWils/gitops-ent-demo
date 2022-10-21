resource "google_cloud_run_service" "core-service" {
  name     = "core-srv"
  location = var.region

  template {
    spec {
      containers {
        image = format("gcr.io/%s/sync-core-svc", var.gcp_project_id)
        env {
          name  = "MESSAGE"
          value = "Welcome to sync core running on Cloud Run and deployed by Terraform"
        }
        env {
          name  = "API_BASE_PATH"
          value = "core"
        }
      }

    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location    = google_cloud_run_service.core-service.location
  project     = google_cloud_run_service.core-service.project
  service     = google_cloud_run_service.core-service.name

  policy_data = data.google_iam_policy.noauth.policy_data
}