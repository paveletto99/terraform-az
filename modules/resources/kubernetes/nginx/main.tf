# https://github.com/kubernetes/ingress-nginx/tree/main/charts/ingress-nginx
# https://docs.nginx.com/nginx-ingress-controller/installation/installation-with-helm/
# https://artifacthub.io/packages/helm/ingress-nginx/ingress-nginx
# https://docs.nginx.com/nginx-ingress-controller/logging-and-monitoring/prometheus/
# https://github.com/kubernetes/ingress-nginx
resource "helm_release" "nginx_ingress_controller" {
  name = "nginx-ingress-controller"

  repository = "https://kubernetes.github.io/ingress-nginx"

  chart            = "ingress-nginx"
  version          = "4.2.3"
  namespace        = "ingress-nginx"
  create_namespace = "true"

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }
  set {
    name  = "controller.autoscaling.enabled"
    value = "true"
  }
  set {
    name  = "controller.autoscaling.minReplicas"
    value = "2"
  }
  set {
    name  = "controller.autoscaling.maxReplicas"
    value = "3"
  }
  # set {
  #   name  = "controller.service.loadBalancerIP"
  #   value = var.load_balancer_ip
  # }
  # Create internal LB
  # set {
  #   name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-internal"
  #   value = "true"
  # }
  # set {
  #   name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-health-probe-request-path"
  #   value = "/healthz"
  # }
  # metrics
  set {
    name  = "controller.metrics.enabled"
    value = var.metrics_enabled
  }
  # set {
  #   name  = "controller.metrics.port"
  #   value = "10254"
  # }
  set {
    name  = "controller.metrics.serviceMonitor.enabled"
    value = "true"
  }
  set {
    name  = "controller.metrics.serviceMonitor.namespace"
    value = "ingress-nginx"
  }
  set {
    name  = "controller.metrics.serviceMonitor.additionalLabels.release"
    value = "ingress-nginx"
  }
  set {
    name  = "controller.metrics.service.annotations\\.prometheus\\.io/scrape"
    value = "true"
  }
  set {
    name  = "controller.metrics.service.annotations\\.prometheus\\.io/port"
    value = "10254"
  }
  # set {
  #   name  = "controller.metrics.service.annotations\\.prometheus\\.io/scheme"
  #   value = "tcp"
  # }

}

# TODO
# The Nginx ingress controller can export Prometheus metrics, by setting controller.metrics.enabled to true.


