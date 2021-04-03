module "dev_tools_namespace" {
  source = "./module"

  cluster_config_file_path = module.dev_cluster.config_file_path
  name                     = var.namespace
}
