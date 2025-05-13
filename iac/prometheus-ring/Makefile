TF_DIR ?= ./terraform
TF_AUTH_FILE ?= $(TF_DIR)/auth.sh
INVENTORY_FILE ?= ./ansible/inventory.yaml
ANSIBLE_PLAYBOOK ?= ./ansible/playbook.yaml
export KUBECONFIG := ./k8s/kubeconfig.yaml
K8S_DIR ?= ./k8s

.PHONY: help deploy destroy terraform inventory ansible clean all

help:
	@echo "Usage: make [deploy|destroy|terraform|inventory|ansible|clean|all]"
	@echo "  deploy             - Deploy prometheus ring on docker swarm and mimir on k8s [TODO]"
	@echo "  deploy-helm        - Deploy consul, mimir and grafana on k8s"
	@echo "  deploy-prom-ring   - Deploy prometheus ring on docker swarm"
	@echo "  destroy            - Remove running services"
	@echo "  terraform          - Run Terraform initialization and apply"
	@echo "  inventory          - Generate Ansible inventory from Terraform output"
	@echo "  ansible            - Runs the Ansible playbook"

# Infraestructure setup
terraform:
	@echo Building terraform infraestructure...
	terraform -chdir=$(TF_DIR) apply

# Infraestructure setup
terraform-plan:
	@echo Planning terraform infraestructure...
	terraform -chdir=$(TF_DIR) plan

inventory:
	@echo Building ansible inventory...
	terraform -chdir=$(TF_DIR) output -json | ./build-inventory $(INVENTORY_FILE)

terraform-destroy:
	terraform -chdir=$(TF_DIR) destroy

ansible:
	@echo "Running Ansible Playbook..."
	ansible-playbook -i $(INVENTORY_FILE) $(ANSIBLE_PLAYBOOK)

# Deployments
## Kubernetes deployment via helm
helm-deploy: helm-repo deploy-consul deploy-mimir deploy-grafana deploy-kube-prometheus

helm-repo:
	helm repo add hashicorp https://helm.releases.hashicorp.com
	helm repo add grafana https://grafana.github.io/helm-charts
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm repo update

deploy-consul:
	@echo "Deploying consul on k8s cluster..."
	helm upgrade --install consul -n consul hashicorp/consul -f $(K8S_DIR)/consul.yaml --create-namespace

deploy-mimir:
	@echo "Deploying mimir on k8s cluster..."
	helm upgrade --install mimir -n mimir grafana/mimir-distributed -f $(K8S_DIR)/mimir.yaml --create-namespace
	@echo "Deploying secret file with s3 credentials"
	kubectl apply -n mimir -f $(K8S_DIR)/mimir-s3-credentials.yaml

deploy-grafana:
	@echo "Deploying grafana on k8s cluster..."
	helm upgrade --install grafana -n grafana grafana/grafana -f $(K8S_DIR)/grafana.yaml --create-namespace

deploy-prometheus:
	@echo "Deploying prometheus on k8s cluster..."
	helm upgrade --install prometheus -n prometheus prometheus-community/prometheus -f $(K8S_DIR)/prometheus.yaml --create-namespace

deploy-kube-prometheus-stack:
# @echo "Deploying kube-prometheus-stack on k8s cluster..."
# helm upgrade --install kube-prometheus-stack -n kube-prometheus prometheus-community/kube-prometheus-stack -f $(K8S_DIR)/kube-prometheus-stack.yaml --create-namespace
	@echo "Deploying Prometheus Ring metamonitoring endpoints"
	kubectl apply -n kube-prometheus -f $(K8S_DIR)/prom-ring-metamonitoring.yaml

deploy-netshoot:
	@echo "Deploying netshoot pod"
	kubectl apply -n kube-prometheus -f $(K8S_DIR)/debug-pod.yaml

## Deploy Prometheus Ring on docker swarm machines
deploy-prom-ring:
	@echo "Deploy Prometheus Ring on Docker Swarm..."
	@MANAGER_NODE=$$(terraform -chdir=$(TF_DIR) output -json | jq -r '.prom_ring_managers_ips.value["manager-0"].public_ip') && \
	scp -o StrictHostKeyChecking=no compose.yaml ubuntu@$$MANAGER_NODE:/tmp/ && \
	ssh -o StrictHostKeyChecking=no ubuntu@$$MANAGER_NODE "docker stack deploy -c /tmp/compose.yaml prometheus-ring" && \
	echo "Service available at $$MANAGER_NODE:9988"
	
# Teardown
## Helm charts
helm-destroy: destroy-consul destroy-mimir destroy-grafana

destroy-consul:
	@echo "Deleting consul deployment on k8s cluster..."
	helm uninstall consul -n consul
	kubectl delete namespace consul

destroy-mimir:
	@echo "Deleting mimir deployment on k8s cluster..."
	helm uninstall mimir -n mimir
	kubectl delete namespace mimir

destroy-grafana:
	@echo "Deleting grafana deployment on k8s cluster..."
	helm uninstall grafana -n grafana
	kubectl delete namespace grafana

destroy-prometheus:
	@echo "Deleting prometheus deployment on k8s cluster..."
	# helm uninstall prometheus -n prometheus
	kubectl delete namespace prometheus

destroy-kube-prometheus-stack:
	@echo "Destroying Prometheus Ring metamonitoring endpoints"
	kubectl delete -n kube-prometheus -f $(K8S_DIR)/prom-ring-metamonitoring.yaml
# 	@echo "Deleting kube-prometheus deployment on k8s cluster..."
# 	helm uninstall kube-prometheus -n kube-prometheus-stack
# 	kubectl delete namespace kube-prometheus-stack

# 	@echo "Deleting kube-prometheus CRDs..."
# 	kubectl delete crd alertmanagerconfigs.monitoring.coreos.com
# 	kubectl delete crd alertmanagers.monitoring.coreos.com
# 	kubectl delete crd podmonitors.monitoring.coreos.com
# 	kubectl delete crd probes.monitoring.coreos.com
# 	kubectl delete crd prometheusagents.monitoring.coreos.com
# 	kubectl delete crd prometheuses.monitoring.coreos.com
# 	kubectl delete crd prometheusrules.monitoring.coreos.com
# 	kubectl delete crd scrapeconfigs.monitoring.coreos.com
# 	kubectl delete crd servicemonitors.monitoring.coreos.com
# 	kubectl delete crd thanosrulers.monitoring.coreos.com

## Docker
destroy-prom-ring:
	@echo "Deleting Prometheus Ring deployment on Docker Swarm cluster..."
	@bash -c '\
		MANAGER_NODE=$$(terraform -chdir=$(TF_DIR) output -json | jq -r ".prom_ring_managers_ips.value[\"manager-0\"].public_ip"); \
		ssh -o StrictHostKeyChecking=no ubuntu@$$MANAGER_NODE "\
			docker service ls | grep prometheus | awk '\''{ print \$$2 }'\'' | while read -r service; do \
				docker service rm \$$service; \
			done && \
			docker stack rm prometheus-ring" \
	'
