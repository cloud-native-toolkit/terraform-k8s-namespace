provider "kubernetes" {
  config_path = var.cluster_config_file_path
}
provider "null" {}

resource "null_resource" "delete_namespace" {
  provisioner "local-exec" {
    command = "${path.module}/scripts/deleteNamespace.sh ${var.name}"

    environment = {
      KUBECONFIG = var.cluster_config_file_path
    }
  }
}

resource "kubernetes_namespace" "tools" {
  depends_on = [null_resource.delete_namespace]

  metadata {
    name = var.name
  }
}

resource "null_resource" "copy_apikey_secret" {
  depends_on = [kubernetes_namespace.tools]

  provisioner "local-exec" {
    command = "${path.module}/scripts/copy-secret-to-namespace.sh ibmcloud-apikey ${var.name}"

    environment = {
      KUBECONFIG = var.cluster_config_file_path
    }
  }
}

resource "null_resource" "copy_cloud_configmap" {
  depends_on = [kubernetes_namespace.tools]

  provisioner "local-exec" {
    command = "${path.module}/scripts/copy-configmap-to-namespace.sh ibmcloud-config ${var.name}"

    environment = {
      KUBECONFIG = var.cluster_config_file_path
    }
  }
}

resource "null_resource" "create_pull_secrets" {
  depends_on = [kubernetes_namespace.tools]

  provisioner "local-exec" {
    command = "${path.module}/scripts/setup-namespace-pull-secrets.sh ${var.name}"

    environment = {
      KUBECONFIG = var.cluster_config_file_path
    }
  }
}
