module "dev_cluster" {
  source = "github.com/cloud-native-toolkit/terraform-ocp-login.git"

  server_url = var.server_url
  user       = "apikey"
  password   = var.ibmcloud_api_key
}
