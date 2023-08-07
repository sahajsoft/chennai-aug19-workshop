terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
      version = "2.5.1"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.21.1"
    }
  }
}

provider "helm" {
  kubernetes {
    config_path    = "~/.kube/config"
	config_context_cluster   = "minikube"
  }
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context_cluster = "minikube"
}

resource "kubernetes_namespace" "chennai-workshop" {
  metadata {
    name = "chennai-workshop"
  }
}

resource "helm_release" "jenkins" {
  name       = "jenkins"
  repository = "https://charts.jenkins.io"
  chart      = "jenkins"
  namespace  = "chennai-workshop"

  values = [
    "${file("jenkins-values.yaml")}"
  ]
}