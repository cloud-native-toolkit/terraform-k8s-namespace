module "dev_tools_namespace" {
  source = "./module"

  cluster_config_file_path = module.dev_cluster.config_file_path
  name                     = var.namespace
}

#handle duplicate namespace (already exists)
module "dev_tools_namespace2" {
  source = "./module"
  depends_on=[module.dev_tools_namespace]

  cluster_config_file_path = module.dev_cluster.config_file_path
  name                     = var.namespace
}
