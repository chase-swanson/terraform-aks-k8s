# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

variable "environment" {
  type        = string
  description = "The suffix to use when naming resources. Values may be [dev, pre, prod]"
  validation {
    condition     = contains(["dev", "pre", "prod"], var.environment)
    error_message = "Environment name must be one of { dev, pre, prod }."
  }
}

variable "location" {
  type        = string
  description = "Define the region the resources should be created."
  default     = "West US2"
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "ID of Log Analytics workspace to attach the cluster"
}

variable "docker_registry_id" {
  type        = string
  description = "ID of container registry to pull Docker images"
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
