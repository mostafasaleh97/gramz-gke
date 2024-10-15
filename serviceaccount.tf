# Define the service account to be used for the instances
resource "google_service_account" "bastion_sa" {
  account_id   = "bastion-sa"
  display_name = "Bastion Service Account"
}

resource "google_project_iam_binding" "cluster-account-iam" {
  project = "my-project-377213"
  role               = "roles/container.admin"           
  members = [
    "serviceAccount:bastion-sa@my-project-377213.iam.gserviceaccount.com",
  ]
  
}
# resource "google_project_iam_binding" "node-account-iam" {
#   project = "my-project-377213"
#   role               = "roles/compute.instances.get"           
#   members = [
#     "serviceAccount:bastion-sa@my-project-377213.iam.gserviceaccount.com",
#   ]
  


# resource "google_project_iam_binding" "admin-account-iam" {
#   project = "my-project-377213"
#   role               = "roles/editor"           
#   members = [
#     "serviceAccount:bastion-sa@my-project-377213.iam.gserviceaccount.com",
#   ]
# }