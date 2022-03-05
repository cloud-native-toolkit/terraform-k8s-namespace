module "dev_cluster" {
  source = "github.com/cloud-native-toolkit/terraform-ocp-login.git"

  server_url = var.server_url
  login_user       = "apikey"
  login_password   = var.ibmcloud_api_key
  login_token = ""
}

resource null_resource write_kubeconfig {
  provisioner "local-exec" {
    command = "echo 'KUBECONFIG=${module.dev_cluster.config_file_path}' > ${path.cwd}/kubeconfig"
  }
}
