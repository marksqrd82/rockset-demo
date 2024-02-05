resource "kubernetes_config_map" "config" {
  metadata {
    namespace = local.namespace
    name      = "config"
  }
  data = {
    "init.sh" = file("${path.module}/scripts/init.sh")
  }
}
