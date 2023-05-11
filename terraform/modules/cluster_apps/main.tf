# Get cluster creds
data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}
data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

# Create k8s namespace
resource "kubernetes_namespace" "ns" {
  metadata {
    name = var.namespace_name
  }
}

# Get image repo
data "aws_ecr_repository" "repo" {
  name = var.ecr_name
}

data "aws_ecr_image" "image" {
  repository_name = var.ecr_name
  most_recent     = true
}

# Create secret to access private ecr images
data "aws_ecr_authorization_token" "ecr_token" {}

data "aws_caller_identity" "current" {}

resource "kubernetes_secret" "secret" {
  metadata {
    name      = "regcred"
    namespace = kubernetes_namespace.ns.metadata[0].name
  }

  type = "kubernetes.io/dockerconfigjson"
  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com" = {
          "auth" = data.aws_ecr_authorization_token.ecr_token.authorization_token
        }
      }
    })
  }
}

# Deploy app
resource "kubernetes_deployment" "kubernetes_deployment" {
  metadata {
    name      = "simple-app"
    namespace = kubernetes_namespace.ns.metadata[0].name

    labels = {
      app = "simpleApp"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "simpleApp"
      }
    }

    template {
      metadata {
        labels = {
          app = "simpleApp"
        }
      }

      spec {
        image_pull_secrets {
          name = kubernetes_secret.secret.metadata[0].name
        }
        container {
          image             = "${data.aws_ecr_repository.repo.repository_url}@${data.aws_ecr_image.image.id}"
          image_pull_policy = "Always"
          name              = "api"

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/msg"
              port = 8080
            }

            initial_delay_seconds = 3
            period_seconds        = 3
          }
        }

      }
    }
  }

  depends_on = [kubernetes_secret.secret]
}

resource "kubernetes_service" "service" {
  metadata {
    name = "${kubernetes_deployment.deploy.metadata.0.name}-service"
  }

  spec {
    selector = {
      app = kubernetes_deployment.deploy.metadata.0.labels.app
    }
    port {
      port        = 80
      target_port = 8080
    }

    type = "LoadBalancer"
  }
}
