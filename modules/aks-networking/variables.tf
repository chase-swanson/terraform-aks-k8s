
# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------
variable "k8s_cluster_name" {
  type        = string
  description = "value"
}

variable "resource_group_name" {
  type        = string
  description = "value"
}

variable "node_resource_group_name" {
  type        = string
  description = "value"
}

variable "system_subnet_id" {
  type        = string
  description = ""
}

variable "user_subnet_id" {
  type        = string
  description = ""
}

variable "gateway_subnet_id" {
  type        = string
  description = ""
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# These parameters have reasonable defaults.
# ---------------------------------------------------------------------------------------------------------------------


variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
