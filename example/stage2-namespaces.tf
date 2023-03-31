module "namespace1" {
  source = "../"

  cluster_config_file_path = module.cluster.config_file_path
  name                     = var.namespace
}

#handle duplicate namespace (already exists)
module "namespace2" {
  source = "../"
  depends_on=[module.namespace1]

  cluster_config_file_path = module.cluster.config_file_path
  name                     = var.namespace
}

#test that openshift- namespace is skipped
module "namespace3" {
  source = "../"
  depends_on=[module.namespace2]

  cluster_config_file_path = module.cluster.config_file_path
  name                     = "openshift-bogus"
}
