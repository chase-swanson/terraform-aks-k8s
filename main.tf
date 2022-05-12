# ---------------------------------------------------------------------------------------------------------------------
# The intent of this Terraform declaration is to provision all environment resources needed for the desk booking
# indicator that are NOT directly tied to an application or micro service.
# ---------------------------------------------------------------------------------------------------------------------

# Monitoring moduled provisions a Log Analytics workspace that is used by multiple resources and applications for aggregation.
module "monitoring" {
  source      = "./modules/monitoring"
  environment = var.environment
  location    = var.location
  tags        = var.tags
}

# The Docker registry module provisions a Container Registry for storing Docker images. This is done prior to AKS provisioning.
# The cluster is given permissions to pull images from the registry via Azure AD role assignments.
module "docker_registry" {
  source      = "./modules/docker-registry"
  environment = var.environment
  location    = var.location
  tags        = var.tags
}

# Module provisons a Kubernetes cluster to the environment for micro service use. This module pulls in a Log Analytics workspace
# and the Docker container registry for connection purposes.
module "aks" {
  source                     = "./modules/aks"
  environment                = var.environment
  location                   = var.location
  tags                       = var.tags
  docker_registry_id         = module.docker_registry.acr_id
  log_analytics_workspace_id = module.monitoring.workspace_id
}

module "k8s" {
  source = "./modules/kubernetes"
}

# module "app_gateway" {
#   source      = "./modules/gateway"
#   environment = var.environment
#   location    = var.location
#   tags        = var.tags
# }

