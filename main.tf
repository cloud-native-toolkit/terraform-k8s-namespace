provider "null" {}

resource "null_resource" "delete_namespace" {
  provisioner "local-exec" {
    command = "${path.module}/scripts/deleteNamespace.sh ${var.name}"

    environment = {
      KUBECONFIG = var.cluster_config_file_path
    }
  }
}

resource "null_resource" "create_namespace" {
  depends_on = [null_resource.delete_namespace]

  triggers = {
    name       = var.name
    kubeconfig = var.cluster_config_file_path
  }

  provisioner "local-exec" {
    command = "kubectl create namespace ${self.triggers.name}"

    environment = {
      KUBECONFIG = self.triggers.kubeconfig
    }
  }

  provisioner "local-exec" {
    when    = destroy
    command = "${path.module}/scripts/deleteNamespace.sh ${self.triggers.name}"

    environment = {
      KUBECONFIG = self.triggers.kubeconfig
    }
  }
}

resource "null_resource" "copy_apikey_secret" {
  depends_on = [null_resource.create_namespace]

  provisioner "local-exec" {
    command = "${path.module}/scripts/copy-secret-to-namespace.sh ibmcloud-apikey ${var.name}"

    environment = {
      KUBECONFIG = var.cluster_config_file_path
    }
  }
}

resource "null_resource" "copy_cloud_configmap" {
  depends_on = [null_resource.create_namespace]

  provisioner "local-exec" {
    command = "${path.module}/scripts/copy-configmap-to-namespace.sh ibmcloud-config ${var.name}"

    environment = {
      KUBECONFIG = var.cluster_config_file_path
    }
  }
}

resource "null_resource" "create_pull_secrets" {
  depends_on = [null_resource.create_namespace]

  provisioner "local-exec" {
    command = "${path.module}/scripts/setup-namespace-pull-secrets.sh ${var.name}"

    environment = {
      KUBECONFIG = var.cluster_config_file_path
    }
  }
}
