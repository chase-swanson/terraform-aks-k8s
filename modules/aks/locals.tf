locals {
  backend_address_pool_name      = "default-backend-address-pool"
  frontend_ip_configuration_name = "app-gateway-frontend-ip"
  http_setting_name              = "default-backend-http-setting"
  listener_name                  = "default-http-listener"
  request_routing_rule_name      = "default-request-routing-rule"

  acr = {
    pull = []

    push = []

    delete = []
  }
}
