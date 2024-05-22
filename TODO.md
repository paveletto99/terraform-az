# BEST PRACTICE

- Variable and Naming Validation refactoring as link
- Consider Splitting Your Deployments Into Layers - https://github.com/terraform-google-modules/terraform-example-foundation
- add try on each module output -- > value = try(aws_security_group.this[0].id, aws_security_group.name_prefix[0].id, "")

- make module input variables like this: https://registry.terraform.io/modules/terraform-iaac/cert-manager/kubernetes/latest
- add remote state
- add merged tag tags = merge({ "Name" = format("%s", var.vnet_name) }, var.vnet_resource_tags)

## OPS

- ADD SEMANTIC VERSION AND PRECOMMIT LIKE IN THIS REPO : https://github.com/terraform-aws-modules/terraform-aws-eks https://pre-commit.com/

## FIXME separate folders like best practices https://cloud.google.com/docs/terraform/best-practices-for-terraform#module-structure

this structure need to be like
project/
├─ packer/
├─ ansible/
├─ terraform/
│ ├─ environments/
│ │ ├─ production/
│ │ │ ├─ apps/
│ │ │ │ ├─ blog/
│ │ │ │ ├─ ecommerce/
│ │ │ ├─ data/
│ │ │ │ ├─ efs-ecommerce/
│ │ │ │ ├─ rds-ecommerce/
│ │ │ │ ├─ s3-blog/
│ │ │ ├─ general/
│ │ │ │ ├─ main.tf
│ │ │ ├─ network/
│ │ │ │ ├─ main.tf
│ │ │ │ ├─ terraform.tfvars
│ │ │ │ ├─ variables.tf
│ │ ├─ staging/
│ │ │ ├─ apps/
│ │ │ │ ├─ ecommerce/
│ │ │ │ ├─ blog/
│ │ │ ├─ data/
│ │ │ │ ├─ efs-ecommerce/
│ │ │ │ ├─ rds-ecommerce/
│ │ │ │ ├─ s3-blog/
│ │ │ ├─ network/
│ │ ├─ test/
│ │ │ ├─ apps/
│ │ │ │ ├─ blog/
│ │ │ ├─ data/
│ │ │ │ ├─ s3-blog/
│ │ │ ├─ network/
│ ├─ modules/
│ │ ├─ apps/
│ │ │ ├─ blog/
│ │ │ ├─ ecommerce/
│ │ ├─ common/
│ │ │ ├─ acm/
│ │ │ ├─ user/
│ │ ├─ computing/
│ │ │ ├─ server/
│ │ ├─ data/
│ │ │ ├─ efs/
│ │ │ ├─ rds/
│ │ │ ├─ s3/
│ │ ├─ networking/
│ │ │ ├─ alb/
│ │ │ ├─ front-proxy/
│ │ │ ├─ vpc/
│ │ │ ├─ vpc-pairing/
├─ tools/

---

TODO

- FIX CODE
- WRITE AND FOLLOW THE RULES DESCRIBED https://www.contino.io/insights/terraform-best-practices
- CAN WE USE data "curl" TO GET THE MANIFEST FILES FROM WEB DIRECTLY

https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs
https://www.terraform.io/language/functions

to upgrade when add or change providers
`terraform init -upgrade`

Adding additional tag to resources

```hcl
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-vpc"
  })
```

### Using terraform workspace to manage multi environment

```bash
# Terraform workspaces enable you to deploy multiple instances of a configuration
# using the same base code with different values for the config. The result is
# separate state files for each workspace. We are going to make use of the
# terraform.workspace value for naming and dynamic configuration values.

# Prepare config
terraform fmt
terraform validate

# For Linux and MacOS
export AWS_ACCESS_KEY_ID=YOUR_ACCESS_KEY
export AWS_SECRET_ACCESS_KEY=YOUR_SECRET_ACCESS_KEY

# For PowerShell
$env:AWS_ACCESS_KEY_ID="YOUR_ACCESS_KEY"
$env:AWS_SECRET_ACCESS_KEY="YOUR_SECRET_ACCESS_KEY"

terraform workspace new Development
terraform workspace list

terraform plan -out m9dev.tfplan
terraform apply m9dev.tfplan

terraform workspace new UAT
terraform workspace list
terraform plan -out m9uat.tfplan
terraform apply m9uat.tfplan

# Don't forget to tear everything down when you're done! You'll have to run
# terraform destroy for each workspace
terraform workspace select Development
terraform destroy -auto-approve

terraform workspace select UAT
terraform destroy -auto-approve

# You can delete a workspace too
terraform workspace show
terraform workspace delete Development
```

export TF_LOG="TRACE"

<!-- https://www.cryingcloud.com/blog/2022/2/21/terraform-and-wsl2-issue -->

## Configurations Using Remote State

Now that we have the infrastructure for remote state provisioned and configured, it’s time to create a Terraform script that will store its state in this remote storage.

Remote state is configured in Terraform scripts by configuring “backend” . A backend is an umbrella term in Terraform and denotes a set of services that Terraform needs for its activities from a management perspective. Backends primarily consist of two important services.

The SAS token needed to connect to the remote state can be supplied during the init command using the -backend-config option, as shown next:

```hcl
terraform init -backend-config="sas_token=?sv=2018-11-09&sr=c&st=2020-12-25&se=2021-10-20&sp=racwdl&spr=https&rscc=max-age%3D5&rscd=inline&rsce=deflate&rscl=en-US&rsct=application%2Fjson&sig=5XpFqR2qgZjdw%2BQKfb%2BXs%2BKbUJTJwpXMiPXVfjzy0gw%3D"
```

After initialization, the rest of the commands such as plan and apply can be executed in a similar fashion as any other Terraform script.Terraform will now know that it should not generate the state file in a local folder (the local folder is the default configuration in the Terraform backend) and instead will generate a state file named prod.terraform.tfstate in remote storage.

## MODULES

publishing the module is optional (a module can be consumed using its local path), it is a good practice to publish the modules to either public or private repositories for further consumption in other solutions and projects.

> ⚠️ TODO - apply best practices
> https://learn.hashicorp.com/tutorials/terraform/pattern-module-creation?in=terraform/modules

### Publishing Module

Modules can be consumed from a variety of sources. The modules created so far were part of the same solution and so the modules could be referenced using a relative path to the module.
Just to reiterate, the source attribute to the resource group module has a path value relative to the current folder.source = "../../modules/resources/groups"

This is just one of the ways to refer to a module out of the myriad ways provided by Terraform.Terraform modules can be published to the Terraform registry.
The Terraform registry is a public centralized location of modules and providers managed and maintained by creators of Terraform. It provides full support for versioning and a native way of publishing modules. The form to uniquely identify a module in the Terraform registry is as follows:<Namespace>/<Name>/<Provider>

An example of consuming a module from the Terraform registry is shown next. This module is responsible for managing Azure networks.Source = "Azure/network/azurerm"

The namespace is Azure, azurerm is the provider, and network is the name of the module. Similarly, the module published at “Azure/compute/azurerm” helps in managing virtual machines:Source = "Azure/compute/azurerm"The provider and namespace name remains azurerm and Azure, respectively, and the name of module is compute in this case.

All modules related to Azure in the Terraform registry are available at https://registry.terraform.io/namespaces/Azure.Terraform modules can be published in versioning controlled repositories like GitHub, Bitbucket and even Azure storage accounts.

The GitHub source should contain the path to the module without the protocol information. The following is an example of a GitHub repo:Source = "github.com/Ritesh/samplemodule"

Similarly, there are examples for consuming Terraform modules from other locations, and they are well documented at https://www.terraform.io/docs/language/modules/sources.html#terraform-registry.Publishing a module involves pushing the code to a GitHub repo and then consuming them from other Terraform configurations using the source attribute, as shown earlier.

### Nested Modules

Modules do not have a root configuration, and they need a root configuration to host the module and execute it. This does not mean that a module cannot contain modules themselves. Modules promote hierarchical authoring of resources. Root configuration relies on their immediate modules, and those modules themselves might rely on other modules. The modules can be nested multiple levels. There is no difference between a nested module and a parent module. They both are authored and consumed in the same way without any differences.

### Module Best Practices

Modules are essentially Terraform scripts with a slight difference in authoring experience but a substantial difference in their usage. Some of the best practices that should be implemented are as follows:

- Modules should be published to a public repository if they are to be shared outside the team and should be published to a private repository if they will be shared within the organization.
- Modules should be shared from a repository like a Terraform repository or GitHub that provides good support from a security perspective.
- Modules should declare their dependence on a provider with regard to a specific version or a range of versions.
- Modules should bring together resources that are logically connected and share the same application lifecycle.
- Modules should be generic enough to be universally usable in the majority of cases. They should accept input variables and use them to be more generic and applied to the majority of cases.
- Modules should validate the input variables and declare both input and output variables as sensitive.
- Modules should not hard-code file paths or any string literal that would render a module less usable.
- Modules should output as much information using an output variable as will help other modules and root configuration to use them to configure other resources and modules. These outputs can help implement rich unit tests using tools like TerraTest.

  Published modules should define their versions using the semver(major:minor:patch) notation. The minor version should be increased for any feature addition or improvement. The patch version should be increased for any small changes or bug fixes and major version for any breaking changes.

### OPS AND BEST PRACTICE

https://github.com/gruntwork-io/terratest/
https://deepsource.io/blog/release-terraform-static-analysis/
https://docs.microsoft.com/en-us/azure/developer/terraform/best-practices-integration-testing
https://github.com/terraform-linters/tflint

Checkov uses a common command line interface to manage and analyze infrastructure as code (IaC) scan results across platforms such as Terraform, CloudFormation, Kubernetes, Helm, ARM Templates and Serverless framework.
https://www.checkov.io/
https://github.com/aquasecurity/tfsec
Do a similar work

to see checkov output in serif format https://microsoft.github.io/sarif-web-component/

try also to add semantic versioning on modules

> Naming convention for this service is as follows:
> service-market-environment-location-product

## UNIT TESTING

A subdirectory named fixtures is part of the modules folder. It has two folders, one for each module. They are even named with the same names as the modules folder name.
These folders contain a root configuration for each module. Executing these fixtures will result in consuming modules and thereby help to test modules.
These fixtures for each module can also act as usage examples for the module.
https://terratest.gruntwork.io/docs/getting-started/quick-start/

https://github.com/gruntwork-io/terratest/tree/master/examples/azure

## REF. LINK

https://github.com/nlarzon/terraform-azure-vnet
https://github.com/zioproto/terraform-azurerm-aks
https://github.com/zioproto/aks-terraform-module-example
https://github.com/zioproto/terraform-azurerm-network
https://github.com/Azure-Terraform/terraform-helm-linkerd
https://github.com/HoussemDellai/terraform-course
https://github.com/kumarvna/terraform-azurerm-vnet/blob/master/main.tf
https://www.stacksimplify.com/azure-aks/create-aks-cluster-using-terraform/
https://github.com/stacksimplify/azure-aks-kubernetes-masterclass/tree/master/24-Azure-AKS-Terraform/24-04-Create-AKS-NodePools-using-Terraform

TO READ
https://github.com/terraform-google-modules/terraform-example-foundation

> [to improve AKS config see](https://github.com/Azure-Terraform/terraform-azurerm-kubernetes)
> [official azure examples](https://github.com/orgs/Azure-Terraform/repositories)

Lets Encypt
https://schnerring.net/blog/use-terraform-to-deploy-an-azure-kubernetes-service-aks-cluster-traefik-2-cert-manager-and-lets-encrypt-certificates/

---

## TOOLS

- [TFSwitch](https://tfswitch.warrensbox.com/) is a command-line tool and solves this problem. It allows you to select the version of Terraform you want to work with and install it automatically.

- [TFLint](https://github.com/terraform-linters/tflint):
  Syntax errors are sometimes not easy to understand when running your code. Linters provide crucial information to speed up debugging and save time in your development. You can also integrate them into your CI/CD pipeline to implement continuous improvement.
  You can use plugins for cloud providers and a TFLint configuration file for custom rules.

- [Terraform-docs](https://github.com/terraform-docs/terraform-docs)
  Documenting your code is an important point for teamwork and reusability. Terraform-docs is a quick utility to generate docs from Terraform modules in various output formats.

- [Checkov](https://www.checkov.io/)
  Checkov is a static code analysis tool for scanning infrastructure as code files including Terraform. It looks for misconfiguration that may lead to security or compliance problems. It has 750 predefined policies to check for common misconfiguration issues.

- [Infracost: Estimate Cloud Cost From Your Code](https://github.com/infracost/infracost)
  Changes made by Terraform may alter the status of resources hosted by a cloud provider. Depending on these, costs may vary. It is important to keep this dimension in mind when writing IaC code.
  Infracost shows cloud cost estimates for infrastructure-as-code projects such as Terraform. It helps to quickly see a cost breakdown and compare different options up front.

[doc](https://www.infracost.io/docs/)

> Infracost shows cloud cost estimates for infrastructure-as-code projects such as Terraform. It helps DevOps, SRE and developers to quickly see a cost breakdown and compare different options upfront. https://github.com/infracost/infracost



Authenticate to infracost

```bash
infracost auth login
```

```bash
infracost breakdown --path .
```

Generate an HTML output format file

```bash
infracost breakdown --path . --format html > out/cost-report.html
```

Generate an Infracost JSON file as the baseline:

```bash
infracost breakdown --path . --format json --out-file infracost-base.json
```

Edit your Terraform project. If you're using our example project, try changing the instance type:

Generate a diff by comparing the latest code change with the baseline:

```bash
infracost diff --path . --compare-to infracost-base.json
```
---
**Visual representation**

https://dev.to/vidyasagarmsc/tools-to-visualize-your-terraform-plan-5g3

Manual write in python
https://diagrams.mingrammer.com/docs/guides/cluster

---

## Deploy an example application

`kubectl apply -f ./k8s-deploy/aks-helloworld-one.yaml --namespace app-test`

`kubectl apply -f ./k8s-deploy/aks-helloworld-two.yaml --namespace app-test`

`kubectl apply -f ./k8s-deploy/hello-world-ingress.yaml --namespace app-test`

---

## K8S

You can use the following command to access the value and save it to disk

`echo "$(terraform output kube_config)" > azurek8s`

You can load that kubeconfig with:

`export KUBECONFIG="${PWD}/azurek8s"`

Assuming you have kubectl installed locally, you can test the connection to the cluster with:

`kubectl get pods --all-namespaces`

Deploy the test app

`kubectl apply -f k8s-deploy/azure-vote.yaml`

You can connect to the Pod with:

`kubectl port-forward svc/<service-name> <local-port>:<remote-port>`

example:

`kubectl port-forward hello-kubernetes-7f65c7597f-8dn2l 8080:8080`

And see the public IP here:

`kubectl get service azure-vote-front --watch`

Get a list of endpoints across all namespaces

`kubectl get ep -A`

Get a list of events sorted by lastTimestamp

`kubectl get events --sort-by=".lastTimestamp"`

Watch all warnings across the namespaces

`kubectl get events -w --field-selector=type=Warning -A`

List the environment variables for a resource

`kubectl set env <resource>/<resource-name> --list`

### Refs

https://lucheeseng.medium.com/deploying-helm-charts-into-k8s-with-terraform-7125fc048647
https://www.cinderblook.com/blog/terraform-azure-k8s-helm/
https://getbetterdevops.io/terraform-with-helm/#what-is-helm
https://kubectl.docs.kubernetes.io/guides/introduction/

<!-- ARM Hardware -->

TODO make this a map and select using function
Standard_Dpds_v5
Standard_DS2_v2

## OBSERVABILITY

https://github.com/isItObservable

## MONITORING

https://medium.com/@dotdc/a-set-of-modern-grafana-dashboards-for-kubernetes-4b989c72a4b2
https://getbetterdevops.io/terraform-with-helm/

TODO monitoring the state of the cluster with https://github.com/kubernetes/kube-state-metrics

create a VM for K6

## LOGGING

fluentd on dynatrace
https://www.youtube.com/watch?v=8I6AnkTkeiI
https://github.com/isItObservable
fluentbit OTEL exporter on jeager
https://www.youtube.com/watch?v=5ofsNyHZwWE

## LOAD TEST

TODO add operator K6 inside the cluster
https://www.youtube.com/watch?v=KPyI8rM3LvE
https://k6.io/blog/running-distributed-tests-on-k8s/

## CHAOS

https://litmuschaos.io/

# CARBON FOOTPRINT

https://www.cloudcarbonfootprint.org/
https://github.com/thegreenwebfoundation/grid-intensity-go
https://medium.com/teads-engineering/building-an-aws-ec2-carbon-emissions-dataset-3f0fd76c98ac
https://grafana.com/grafana/dashboards/11010-kube-carbon/

# DevSecOps

**Preparation**
There are a few steps as part of the preparation that should be executed before we can execute the Terraform scripts. These preparation steps should ideally be automated.
A storage account should be created with a container to store the Terraform state files. The storage account is used as a remote Terraform state.

As a good practice, all secrets should be stored in a key vault. As part of the preparation, we need a vault to store our secrets and sensitive information.
For the purpose of this chapter, we need two sets of secrets.

- Secrets related to service principal authentication to Azure. This involves storing client_id, tenant_id, subscription_id, and client_secret in a key vault.
- Information related to storing the Terraform state file in remote Azure blob storage. This involves storing the storage account name, the resource group of the storage account, the container name within the storage account, the name of the state file, and the access token related to the storage account.


Once we have retrieved the key vault secrets, we need to execute Terraform commands and Golang-based unit and integration tests. We also need other tools to validate and scan our Terraform scripts. The next code snippet installs Terraform version 0.14.10. It is a good practice to use version numbers in pipelines.

## NETWORK

**Service endpoints vs subnet delegation and basic vnet configuration**


The primary difference between delegation and service endpoints with virtual networks (vnets):

delegation means a given subnet is only going to be used by that service (this is related to PaaS services)
service endpoint is allowing secure and direct connectivity for that service to the subnet assigned
An example of the above:

**Delegation**

Deploying App Services is one of the most common Azure services that requires a dedicated subnet be allocated just for that service, aka delegation.

**Service Endpoint**

Deploying a Virtual Machine that you need to access a Storage Account from? The subnet where the Virtual Machine is deployed will need to have the Microsoft.Storage service endpoint enabled to allow the secure, direct connection to it.

One thing to note on service endpoints, while they are still used Microsoft recommends use of Private Endpoints as well. This allows you to directly connect to the service endpoint over the private/internal network of your VNet.
