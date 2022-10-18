
data clis_check clis {
  clis = ["kubectl","jq"]
}

resource "null_resource" "create_namespace" {

  triggers = {
    name       = var.name
    kubeconfig = var.cluster_config_file_path
    bin_dir    = data.clis_check.clis.bin_dir
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/createNamespace.sh ${self.triggers.name}"

    environment = {
      BIN_DIR = self.triggers.bin_dir
      KUBECONFIG = self.triggers.kubeconfig
    }
  }

  provisioner "local-exec" {
    when    = destroy
    command = "${path.module}/scripts/deleteNamespace.sh ${self.triggers.name}"

    environment = {
      BIN_DIR = self.triggers.bin_dir
      KUBECONFIG = self.triggers.kubeconfig
    }
  }
}

resource "null_resource" "create_operator_group" {
  depends_on = [null_resource.create_namespace]
  count = var.create_operator_group ? 1 : 0

  triggers = {
    name       = var.name
    kubeconfig = var.cluster_config_file_path
    bin_dir    = data.clis_check.clis.bin_dir
  }

  provisioner "local-exec" {
    command = "${path.module}/scripts/createOperatorGroup.sh ${self.triggers.name}"

    environment = {
      BIN_DIR = self.triggers.bin_dir
      KUBECONFIG = self.triggers.kubeconfig
    }
  }

  provisioner "local-exec" {
    when = destroy
    command = "${path.module}/scripts/deleteOperatorGroup.sh ${self.triggers.name}"

    environment = {
      BIN_DIR = self.triggers.bin_dir
      KUBECONFIG = self.triggers.kubeconfig
    }
  }
}

resource "null_resource" "copy_cloudnative_secrets" {
  depends_on = [null_resource.create_namespace]

  provisioner "local-exec" {
    command = "${path.module}/scripts/copy-cloudnative-resources-to-namespace.sh secret ${var.name}"

    environment = {
      BIN_DIR = data.clis_check.clis.bin_dir
      KUBECONFIG = var.cluster_config_file_path
    }
  }
}

resource "null_resource" "copy_cloudnative_configmaps" {
  depends_on = [null_resource.create_namespace]

  provisioner "local-exec" {
    command = "${path.module}/scripts/copy-cloudnative-resources-to-namespace.sh configmap ${var.name}"

    environment = {
      BIN_DIR = data.clis_check.clis.bin_dir
      KUBECONFIG = var.cluster_config_file_path
    }
  }
}
