
variable "ingress_class" {
  description = "name of the ingress class to route through this controller"
  type        = string
  default     = "nginx"
}

variable "ingress_type" {
  description = "Internal or Public."
  type        = string
  default     = "Public"

  validation {
    condition = (
      var.ingress_type == "Internal" ||
      var.ingress_type == "Public"
    )
    error_message = "Value of ingress_type must be one of 'Internal' or 'Public'."
  }

}

variable "metrics_enabled" {
  description = "enable Nginx ingress controller to export Prometheus metrics"
  type        = string
  default     = "false"
}

# provider k8s connection
variable "k8s_host" {
  type = string
}
variable "k8s_client_certificate" {
  type = string
}
variable "k8s_client_key" {
  type = string
}
variable "k8s_cluster_ca_certificate" {
  type = string
}
