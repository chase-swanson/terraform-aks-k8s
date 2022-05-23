resource "kubernetes_namespace_v1" "test_ns" {
  metadata {
    name = "sandbox"
  }
}

# resource "helm_release" "nginx_ingress" {
#   name = "app-gw-ingress-controller"

#   repository = "https://appgwingress.blob.core.windows.net/ingress-azure-helm-package/"
#   chart      = "application-gateway-kubernetes-ingress"

#   set {
#     name  = "verbosityLevel"
#     value = 3
#   }
#   set {
#     name  = "appgw.subscriptionId"
#     value = ""
#   }

#   set {
#     name  = "appgw.resourceGroup"
#     value = ""
#   }

#   set {
#     name  = "appgw.name"
#     value = ""
#   }

#   set {
#     name  = "appgw.usePrivateIp"
#     value = false
#   }

#   set {
#     name  = "appgw.shared"
#     value = false
#   }

#   set {
#     name  = "kubernetes.watchNamespace"
#     value = "sandbox"
#   }

#   set {
#     name  = "armAuth.type"
#     value = "aadPodIdentity"
#   }

#   set {
#     name  = "armAuth.identityResourceID"
#     value = ""
#   }

#   set {
#     name  = "armAuth.idenityClientID"
#     value = ""
#   }

#   set {
#     name  = "rbac.enabled"
#     value = false
#   }
# }

