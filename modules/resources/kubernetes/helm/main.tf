resource "helm_release" "chart" {
  name       = var.helm_chart
  repository = var.helm_chart_repository
  chart      = var.helm_chart_name
  namespace  = var.helm_chart_namespace
}


