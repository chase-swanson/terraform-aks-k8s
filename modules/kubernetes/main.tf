resource "kubernetes_namespace_v1" "test_ns" {
  metadata {
    name = "sandbox"
  }
}

resource "helm_release" "nginx_ingress" {
  name = "nginx-ingress-controller"

  repository = "https://appgwingress.blob.core.windows.net/ingress-azure-helm-package/"
  chart      = "application-gateway-kubernetes-ingress"

  set {
    name  = "service.type"
    value = "ClusterIP"
  }
}

