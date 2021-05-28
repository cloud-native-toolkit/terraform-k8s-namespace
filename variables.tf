variable "cluster_config_file_path" {
  type        = string
  description = "The path to the config file for the cluster"
}

variable "name" {
  type        = string
  description = "The namespace that should be created"
}

variable "create_operator_group" {
  type        = bool
  description = "Flag indicating that an operator group should be created in the namespace"
  default     = true
}
