terraform {
  required_providers {
    helm    = { source = "hashicorp/helm" }
    local   = { source = "hashicorp/local" }
    kubectl = { source = "gavinbunney/kubectl" }
  }
}
