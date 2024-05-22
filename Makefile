export ARM_CLIENT_ID="<APPID_VALUE>"
export ARM_CLIENT_SECRET="<PASSWORD_VALUE>"
export ARM_SUBSCRIPTION_ID="<SUBSCRIPTION_ID>"
export ARM_TENANT_ID="<TENANT_VALUE>"


export TF_VAR_sp_client_id=${ARM_CLIENT_ID}
export TF_VAR_sp_client_secret=${ARM_CLIENT_SECRET}

export TERRA_ENV=dev
export TFLINT_LOG=info
# export KUBE_CONFIG_PATH=./kubeconfig

# infracost
export INFRACOST_API_KEY=<KEY_VALUE>

export CONTAINER_RUNTIME = docker

PATH_TO_FILE = ${PWD}/environments/kubeconfig

.PHONY: init check plan apply destroy cleanup infracost

init:
	terraform -chdir=environments init

get-az-k8s-versions:
	az login --service-principal --username ${ARM_CLIENT_ID} --tenant ${ARM_TENANT_ID}  --password ${ARM_CLIENT_SECRET}
	az aks get-versions --location westeurope

check:
	$(info ************ ✅ Run linting ************)
	terraform -chdir=environments fmt
	terraform -chdir=environments validate
	tflint --recursive --fix
	tflint --chdir=modules --config=".tflint.hcl"
	tflint --chdir=environments/. --config=".tflint.hcl"
# ${CONTAINER_RUNTIME} run --rm -v ${PWD}/:/data -t ghcr.io/terraform-linters/tflint-bundle:v0.40.1.0

sec-check:
	tfsec ./environments
	tfsec ./modules
# ${CONTAINER_RUNTIME} run --rm -it -v "${PWD}:/src" aquasec/tfsec /src

policy-check:
	${CONTAINER_RUNTIME} run --rm --tty -v "${PWD}:/tf" --workdir /tf bridgecrew/checkov --directory /tf -o sarif -o cyclonedx --output-file-path ${PWD}/out/


plan:
	cd environments
	terraform workspace select --or-create ${TERRA_ENV}
	terraform -chdir=environments plan -var-file="./varvalues/${TERRA_ENV}.tfvars"

apply:
	terraform workspace select ${TERRA_ENV}
	terraform -chdir=environments apply -var-file="./varvalues/${TERRA_ENV}.tfvars" -auto-approve
	terraform show
	terraform output

destroy:
	terraform workspace select ${TERRA_ENV}
	terraform -chdir=environments destroy -var-file="./varvalues/${TERRA_ENV}.tfvars" -auto-approve

cleanup:
	rm -f ${PWD}/environments/terraform.tfstate
	rm -rf ${PWD}/environments/.terraform/
	rm -f ${PWD}/environments/.kubeconfig

gen-doc:
	terraform-docs markdown --output-file README.md ./modules/resources/kubernetes/aks
#	${CONTAINER_RUNTIME} run --rm --volume "${PWD}:/terraform-docs" -u $(id -u) quay.io/terraform-docs/terraform-docs:0.16.0 markdown /terraform-docs > INFRA.md

infracost-auth:
	infracost auth login

infracost-run:
	infracost breakdown --path=.


# TODO try k8s bench https://github.com/aquasecurity/kube-bench

# test-k8s:
# 	ifeq (,)
#     	export KUBECONFIG="${PWD}/kubeconfig"
# 		whoami := $(shell whoami)
# 		chown $(whoami):$(whoami) ${PWD}/kubeconfig
# 		chmod 644 ./kubeconfig
# 		kubectl get pods --all-namespaces
# 		az aks get-credentials --resource-group $(terraform output -raw resource_group_name) --name $(terraform output -raw kubernetes_cluster_name) --overwrite-existing --file ${PWD}/kubeconfig
# 		kubectl apply -f ${PWD}/k8s-deploy/azure-vote.yaml
# 		kubectl get pods
# 		kubectl config view
# 	else
# 		$(error "👻 No k8s config file found")
# 	endif


# k8s-deploy-test-app:
# 	export KUBECONFIG="${PWD}/kubeconfig"
# 	echo '⚒️ Check the load balancer service ...'
# 	kubectl get services --namespace ingress -o wide
# 	kubectl apply -f ./k8s-deploy/aks-helloworld-one.yaml --namespace ingress
#     kubectl apply -f ./k8s-deploy/aks-helloworld-two.yaml --namespace ingress
# 	kubectl apply -f ./k8s-deploy/hello-world-ingress.yaml --namespace ingress
