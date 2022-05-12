# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

variable "environment" {
  type        = string
  description = "The suffix to use when naming resources. Values may be [dev, uat, prod]"
  validation {
    condition     = contains(["dev", "uat", "prod"], var.environment)
    error_message = "Environment name must be one of { dev, uat, prod }."
  }
}

variable "location" {
  type        = string
  description = "Define the region the resources should be created."
  default     = "West US2"
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
