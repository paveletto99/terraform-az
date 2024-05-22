resource "kubernetes_namespace" "namespace" {
  metadata {
    name = var.name_namespace

    labels = var.akv_labels
  }
  lifecycle {
    ignore_changes = [metadata]
  }
}
