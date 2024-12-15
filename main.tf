provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_namespace" "example" {
  metadata {
    name = "flask-app"
  }
}

resource "kubernetes_deployment" "flask" {
  metadata {
    name      = "flask-app"
    namespace = kubernetes_namespace.example.metadata[0].name
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "flask-app"
      }
    }
    template {
      metadata {
        labels = {
          app = "flask-app"
        }
      }
      spec {
        container {
          image = "flask-hello-world:latest"
          name  = "flask-container"
          image_pull_policy = "IfNotPresent"
          port {
            container_port = 5000
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "flask" {
  metadata {
    name      = "flask-service"
    namespace = kubernetes_namespace.example.metadata[0].name
  }

  spec {
    selector = {
      app = "flask-app"
    }

    # Use NodePort for Minikube compatibility
    type = "NodePort"

    port {
      port        = 80
      target_port = 5000
      # NodePort range is 30000-32767
      node_port   = 30080
    }
  }
}