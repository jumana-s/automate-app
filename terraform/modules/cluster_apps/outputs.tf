output "app-link" {
  value = kubernetes_service.service.hostname
}
