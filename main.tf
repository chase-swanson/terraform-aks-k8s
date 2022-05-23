# ---------------------------------------------------------------------------------------------------------------------
# The intent of this Terraform declaration is to provision all environment resources needed for the desk booking
# indicator that are NOT directly tied to an application or micro service.
# ---------------------------------------------------------------------------------------------------------------------

# Module provisons a Kubernetes cluster to the environment for micro service use. This module pulls in a Log Analytics workspace
# and the Docker container registry for connection purposes.
module "aks" {
  source      = "./modules/aks"
  environment = var.environment
  location    = var.location
  tags        = var.tags
  # docker_registry_id         = module.docker_registry.acr_id
  # log_analytics_workspace_id = module.monitoring.workspace_id
}

# module "k8s" {
#   source = "./modules/kubernetes"
# }

module "aks_network" {
  source = "./modules/aks-networking"

  depends_on = [
    module.aks
  ]
}


