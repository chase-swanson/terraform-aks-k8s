resource "kubernetes_namespace_v1" "test_ns" {
  metadata {
    name = "sandbox"
  }
}
