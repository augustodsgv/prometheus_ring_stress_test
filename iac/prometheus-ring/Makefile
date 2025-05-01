TF_DIR ?= ./terraform
TF_AUTH_FILE ?= $(TF_DIR)/auth.sh
KUBECONFIG ?= ./k8s/kubeconfig.yaml
HELM_DIR ?= ./k8s
INVENTORY_FILE ?= ./ansible/inventory.yaml
ANSIBLE_PLAYBOOK ?= ./ansible/playbook.yaml

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
helm-deploy: helm-repo helm-deploy-consul helm-deploy-mimir helm-deploy-grafana

helm-repo:
	helm repo add hashicorp https://helm.releases.hashicorp.com
	helm repo add grafana https://grafana.github.io/helm-charts
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm repo update

helm-deploy-consul:
	@echo "Deploying consul on k8s cluster..."
	helm upgrade --install consul -n consul hashicorp/consul -f $(HELM_DIR)/consul/values.yaml --create-namespace

helm-deploy-mimir:
	@echo "Deploying mimir on k8s cluster..."
	helm upgrade --install mimir -n mimir grafana/mimir-distributed -f $(HELM_DIR)/mimir/values.yaml --create-namespace

helm-deploy-grafana:
	@echo "Deploying grafana on k8s cluster..."
	helm upgrade --install grafana -n mimir grafana/grafana -f $(HELM_DIR)/grafana/values.yaml --create-namespace

helm-deploy-kube-prometheus:
	@echo "Deploying kube-prometheus on k8s cluster..."
	helm upgrade --install kube-prometheus -n kube-prometheus prometheus-community/kube-prometheus-stack -f $(HELM_DIR)/kube-prometheus/values.yaml --create-namespace

## Deploy Prometheus Ring on docker swarm machines
docker-deploy:
	@echo "Deploy Prometheus Ring on Docker Swarm..."
	@MANAGER_NODE=$$(terraform -chdir=$(TF_DIR) output -json | jq -r '.prom_ring_managers_ips.value["manager-0"].public_ip') && \
	scp -o StrictHostKeyChecking=no compose.yaml ubuntu@$$MANAGER_NODE:/tmp/ && \
	ssh -o StrictHostKeyChecking=no ubuntu@$$MANAGER_NODE "docker stack deploy -c /tmp/compose.yaml prometheus-ring"

# Teardown
## Helm charts
helm-destroy: helm-destroy-consul helm-destroy-mimir helm-destroy-grafana

helm-destroy-consul:
	@echo "Deleting consul deployment on k8s cluster..."
	helm uninstall consul -n consul
	kubectl delete namespace consul

helm-destroy-mimir:
	@echo "Deleting mimir deployment on k8s cluster..."
	helm uninstall mimir -n mimir
	kubectl delete namespace mimir

helm-destroy-grafana:
	@echo "Deleting grafana deployment on k8s cluster..."
	helm uninstall grafana -n grafana
	kubectl delete namespace grafana

helm-destroy-kube-prometheus:
	@echo "Deleting kube-prometheus deployment on k8s cluster..."
	helm uninstall kube-prometheus -n kube-prometheus
	kubectl delete namespace kube-prometheus

	@echo "Deleting kube-prometheus CRDs..."
	kubectl delete crd alertmanagerconfigs.monitoring.coreos.com
	kubectl delete crd alertmanagers.monitoring.coreos.com
	kubectl delete crd podmonitors.monitoring.coreos.com
	kubectl delete crd probes.monitoring.coreos.com
	kubectl delete crd prometheusagents.monitoring.coreos.com
	kubectl delete crd prometheuses.monitoring.coreos.com
	kubectl delete crd prometheusrules.monitoring.coreos.com
	kubectl delete crd scrapeconfigs.monitoring.coreos.com
	kubectl delete crd servicemonitors.monitoring.coreos.com
	kubectl delete crd thanosrulers.monitoring.coreos.com

## Docker
docker-destroy:
	@echo "Deleting Prometheus Ring deployment on Docker Swarm cluster..."
	@MANAGER_NODE=$$(terraform -chdir=$(TF_DIR) output -json | jq -r '.prom_ring_managers_ips.value["manager-0"].public_ip') && \
	ssh -o StrictHostKeyChecking=no ubuntu@$$MANAGER_NODE docker stack rm prometheus-ring