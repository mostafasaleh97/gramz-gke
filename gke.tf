resource "google_container_cluster" "private_gke_cluster" {
  provider = "google-beta"
  project = "my-project-377213"
  name               = "private-gke-cluster"
  location           = "us-central1"
  # remove_default_node_pool = true
  initial_node_count = 1  # No initial nodes
  deletion_protection = false
  node_locations = [ "us-central1-a", "us-central1-b", "us-central1-c" ]
  default_max_pods_per_node = 100
  network    = google_compute_network.vpc_network.name
  subnetwork = google_compute_subnetwork.private_subnet_1.name
  cluster_autoscaling{
    auto_provisioning_defaults {
      management {
        auto_upgrade = true
        auto_repair = true
        }
      upgrade_settings {
        max_surge       = 1
        max_unavailable = 1
        }
      }
    }
  
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = true
    master_ipv4_cidr_block  = "10.0.5.0/28"  # Custom IP range for master endpoint
    
  }
  
  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"
  
  workload_identity_config {
    workload_pool = "my-project-377213.svc.id.goog"
  }

  # Node configuration
  node_config {
    machine_type  = "e2-medium"
    image_type = "ubuntu_containerd"
    disk_size_gb  = 50  # Disk size (ensure it fits within quota)
    
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write"
    ]
    
  }



  release_channel {
    channel = "STABLE"
  }

  # Enable network policy
  network_policy {
    enabled = true
  }

  # Access configuration
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "10.0.1.0/24"  # Public subnet 1
      display_name = "Public Subnet 1"
    }
    # Add more subnets if needed
  }
  
  addons_config {
    network_policy_config {
        disabled = false
      }
    istio_config {
        disabled = false
    }
    
  }
 
  lifecycle {
    create_before_destroy = true
  }
}




# resource "google_container_node_pool" "private_node_pool_1" {
#   name       = "private-node-pool-1"
#   location   = google_container_cluster.private_gke_cluster.location
#   cluster    = google_container_cluster.private_gke_cluster.name
#   node_count = 1
#   autoscaling {
#     max_node_count = 1
#     min_node_count = 1
#   }
#   max_pods_per_node = 100
  
#   node_config {
#     machine_type = "e2-medium"  # Adjust the machine type as needed
#     disk_size_gb = 100 
#     image_type = "ubuntu_containerd"
#     oauth_scopes = [
#       "https://www.googleapis.com/auth/logging.write",
#       "https://www.googleapis.com/auth/monitoring.write"
#     ]
#     # Caching configuration
#     workload_metadata_config {
#       mode = "GKE_METADATA"
#     } 
#   }

#   management {
#     auto_upgrade = true
#     auto_repair = true
#   }
#   upgrade_settings {
#     max_surge       = 1
#     max_unavailable = 1
#   }
# }



resource "google_compute_firewall" "allow_gke_access" {
  name    = "allow-gke-access"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443"]  # Allow SSH, HTTP, and HTTPS
  }

  source_ranges = [
    "10.0.1.0/24",  # Public subnet 1
    # "10.0.2.0/24"   # Public subnet 2
  ]  # Allow access only from the public subnets
}


resource "google_compute_firewall" "egress_rule" {
  name    = "allow-egress-all"
  network = google_compute_network.vpc_network.name

  # Egress rule to allow all outbound traffic
  direction = "EGRESS"

  # Allow all protocols and ports
  allow {
    protocol = "all"
  }

  # Apply to all instances in the network
  destination_ranges = ["0.0.0.0/0"]

  # Priority is optional, default is 1000, lower numbers indicate higher priority
  priority = 1000
}
