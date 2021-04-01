output "name" {
  value       = var.name
  description = "Namespace name"
  depends_on  = [
    null_resource.copy_cloudnative_configmaps,
    null_resource.copy_cloudnative_secrets
  ]
}
