

# Create the Bastion VM
resource "google_compute_instance" "bastion" {
  name         = "bastion"
  machine_type = "e2-medium"
  zone         = "us-central1-a"

  # Use public subnet 1
  network_interface {
    subnetwork = google_compute_subnetwork.public_subnet_1.name

    # Assign a public IP
    access_config {
      // Ephemeral public IP
    }
  }

  # Use Ubuntu 20.04
  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
      size  = 30
    }
  }

  service_account {
    email  = google_service_account.bastion_sa.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  tags = ["bastion"]

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/gitlab.pub")}"
  }
}

# Create the Proxy VM
# resource "google_compute_instance" "proxy" {
#   name         = "proxy"
#   machine_type = "e2-medium"
#   zone         = "us-central1-a"

#   # Use public subnet 1
#   network_interface {
#     subnetwork = google_compute_subnetwork.public_subnet_1.name

#     # Assign a public IP
#     access_config {
#       // Ephemeral public IP
#     }
#   }

#   # Use Ubuntu 20.04
#   boot_disk {
#     initialize_params {
#       image = "ubuntu-os-cloud/ubuntu-2004-lts"
#       size  = 30
#     }
#   }

#   service_account {
#     email  = google_service_account.proxy_sa.email
#     scopes = ["https://www.googleapis.com/auth/cloud-platform"]
#   }

#   tags = ["proxy"]

#   metadata = {
#     ssh-keys = "ubuntu:${file("~/.ssh/gitlab.pub")}"
#   }
# }




# Output the public IPs of both VMs
output "bastion_public_ip" {
  value = google_compute_instance.bastion.network_interface.0.access_config.0.nat_ip
}


