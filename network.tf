
resource "google_compute_network" "vpc_network" {
  name                    = "my-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "public_subnet_1" {
  name          = "public-subnet-1"
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-central1"
  network       = google_compute_network.vpc_network.name
}

# resource "google_compute_subnetwork" "public_subnet_2" {
#   name          = "public-subnet-2"
#   ip_cidr_range = "10.0.2.0/24"
#   region        = "us-central1"
#   network       = google_compute_network.vpc_network.name
# }

resource "google_compute_subnetwork" "private_subnet_1" {
  name          = "private-subnet-1"
  ip_cidr_range = "10.0.3.0/24"
  region        = "us-central1"
  network       = google_compute_network.vpc_network.name
}

# resource "google_compute_subnetwork" "private_subnet_2" {
#   name          = "private-subnet-2"
#   ip_cidr_range = "10.0.4.0/24"
#   region        = "us-central1"
#   network       = google_compute_network.vpc_network.name
# }

# resource "google_compute_address" "nat_ip" {
#   name   = "nat-ip"
#   region = "us-central1"
# }

resource "google_compute_router" "nat_router" {
  name    = "nat-router"
  region  = "us-central1"
  network = google_compute_network.vpc_network.name
}

resource "google_compute_router_nat" "nat_gateway" {
  name   = "nat-gateway"
  region = google_compute_router.nat_router.region
  router = google_compute_router.nat_router.name

  nat_ip_allocate_option = "AUTO_ONLY"
#   nat_ips                = [google_compute_address.nat_ip.address]
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name          = google_compute_subnetwork.private_subnet_1.name
    source_ip_ranges_to_nat = ["10.0.3.0/24"]
  }

  # subnetwork {
  #   name          = google_compute_subnetwork.private_subnet_2.name
  #   source_ip_ranges_to_nat = ["10.0.4.0/24"]
  # }
  
}

resource "google_compute_firewall" "allow_all" {
  name    = "allow-all-traffic"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"] # Accept traffic from any source
}

