
In case of following errors 


> 💥Error: Get “http://localhost/api/v1/namespaces/demo": dial tcp 127.0.0.1:80: connect: connection refused
>Or I also saw something like this:

>Error: Kubernetes cluster unreachable: invalid configuration: no configuration has been provided, try setting >KUBERNETES_MASTER environment variable

Official explanation


> ⚠️ **WARNING**
> 
>When using interpolation to pass credentials to the Kubernetes provider from other resources, these resources SHOULD NOT be created in the same Terraform module where Kubernetes provider resources are also used. This will lead to intermittent and unpredictable errors which are hard to debug and diagnose. The root issue lies with the order in which Terraform itself evaluates the provider blocks vs. actual resources.

[more here](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs#exec-plugins)


> 🧑🏻‍💻 **SOLVED !** -> by upgrading terraform providers

---


>  💥 Error: rendered manifests contain a resource that already exists. Unable to continue with install: Secret "grafana" in namespace "monitoring" exists and cannot be imported into the current release: invalid ownership metadata; label validation error: missing key "app.kubernetes.io/managed-by": must be set to "Helm"; annotation validation error: missing key "meta.helm.sh/release-name": must be set to "grafana"; annotation validation error: missing key "meta.helm.sh/release-namespace": must be set to "monitoring"

> 🧑🏻‍💻 **SOLVED !** -> manually delete k8s secret `kubeconfig delete secret/grafana -n monitoring`

---
When terraform destroy return an error :
>  Error: Get "http://localhost/api/v1/namespaces/monitoring": dial tcp 127.0.0.1:80: connect: connection refused

Try to remove the HELM state release `terraform state rm helm_release.prometheus`