terraform {
  required_providers {
    google = {
        source  = "hashicorp/google"
        version = "6.8.0"
    }
    random = {
        source = "hashicorp/random"
        version = "2.3.0"
    }
  }
}

resource "random_id" "res_id" {
    byte_length = 8
}

output "rid" {
    value = random_id.res_id.hex
}

provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}

resource "google_compute_network" "vpc_network" {
  name = "tf-network"
}

resource "google_compute_instance" "vm_instance" {
    name         = "tf-instance"
    machine_type = "e2-micro"
    tags         = ["web", "dev"]
    boot_disk {
        initialize_params {
            image = "cos-cloud/cos-stable"
        }
    }

    network_interface {
        network = google_compute_network.vpc_network.name
        access_config {
        }
    }
}

resource "google_storage_bucket" "tf_state" {
    name = "ts-appengine-terraform-tfstate-${random_id.res_id.hex}"
    force_destroy = false
    location = "US"
    storage_class = "STANDARD"
    versioning {
        enabled = true    
    }
}

resource "google_app_engine_application" "ts-appengine-app" {
    project = var.project
    location_id = var.region
}


output "ip" {
    value = google_compute_instance.vm_instance.network_interface.0.network_ip
}
