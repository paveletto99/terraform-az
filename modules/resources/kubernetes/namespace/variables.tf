variable "name_namespace" {
  type = string
}
variable "akv_labels" {
  type    = map(any)
  default = null
}
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
