variable "path" {
    default="C:/Users/THLOHITH/Desktop/terraformdemo/demo1/analysis"
}
provider "google" {
  credentials="${file("${var.path}/asset1.json")}"
  project     = "gcp-ngt-training"
  region      = "us-central1"
}
variable "zone" {
    type = list(string)
    default=["us-central1-a","us-central1-b","us-central1-c"]     
}
variable "project" {
    default = "gcp-ngt-training"
}


#creating instance(creating web server)
resource "google_compute_instance" "default" {
  count=3
  name         = "instance-${count.index+1}"
  #for_each = var.zone
  zone         = var.zone[count.index]
  machine_type = "f1-micro"
  boot_disk {
    initialize_params {
     image = "debian-cloud/debian-9"
    }
  }
  network_interface {
      network = "default"
    access_config {
      # Allocate a one-to-one NAT IP to the instance
    }
  }

    #Apply the firewall rule to allow external IPs to access this instance
    tags = ["http-server"]
}
#create a storage bucket
resource "google_storage_bucket" "standard" {
  name          = "assetmanagement-bucket1"
  storage_class = "standard"
  location      = "US"
  force_destroy = true
}
#enable cloud asset api
resource "google_project_service" "api" {
  project = var.project
  service = "cloudasset.googleapis.com"

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_dependent_services = true
}
#enable cloud resource manager api
resource "google_project_service" "api1" {
  project = var.project
  service = "cloudresourcemanager.googleapis.com"

  timeouts {
    create = "30m"
    update = "40m"
  }

  disable_dependent_services = true
}
#upload csv file in bucket
resource "google_storage_bucket_object" "csv-file" {
  name   = "asset-inventory1"
  source = "C:/Users/THLOHITH/Downloads/report.csv"
  bucket = google_storage_bucket.standard.name
}