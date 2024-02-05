resource "kubernetes_namespace" "rockset" {
  metadata {
    name = local.namespace
  }
}

resource "kubernetes_deployment" "rockset" {
  metadata {
    name      = "deployment-demo"
    namespace = local.namespace
    labels = {
      app = "rockset"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "rockset"
      }
    }

    template {
      metadata {
        labels = {
          app = "rockset"
        }
      }

      spec {
        container {
          image = "nginx:1.21.6"
          name  = "rockset"

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }

          env {
            name = "K8_NODE_NAME"
            value_from {
              field_ref {
                field_path = "spec.nodeName"
              }
            }
          }
          env {
            name = "K8_POD_NAME"
            value_from {
              field_ref {
                field_path = "metadata.name"
              }
            }
          }
          env {
            name = "K8_POD_NAMESPACE"
            value_from {
              field_ref {
                field_path = "metadata.namespace"
              }
            }
          }
          env {
            name = "K8_POD_IP"
            value_from {
              field_ref {
                field_path = "status.podIP"
              }
            }
          }

          volume_mount {
            name       = "config-volume"
            mount_path = "/init"
          }

          lifecycle {
            post_start {
              exec {
                command = ["/bin/sh", "-c", "/init/init.sh"]
              }
            }
          }


          liveness_probe {
            http_get {
              path = "/"
              port = 80

              http_header {
                name  = "X-Custom-Header"
                value = "Awesome"
              }
            }

            initial_delay_seconds = 3
            period_seconds        = 3
          }
        }

        volume {
          name = "config-volume"
          config_map {
            name         = "config"
            default_mode = "0555"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "app" {
  metadata {
    name      = "service-demo"
    namespace = local.namespace
  }
  spec {
    selector = {
      app = kubernetes_deployment.rockset.metadata[0].labels.app
    }

    port {
      port        = 80
      target_port = 80
      protocol    = "TCP"
    }

    type = "LoadBalancer"
  }

  depends_on = [kubernetes_deployment.rockset]
}
