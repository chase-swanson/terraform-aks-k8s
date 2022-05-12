resource "kubernetes_namespace_v1" "dbki_ns" {
  metadata {
    name = "sandbox"
  }
}
