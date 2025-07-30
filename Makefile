# Makefile for deploying a High-Availability Redis Cluster with Prometheus Monitoring

# Variables
REDIS_NAMESPACE := redis
PROMETHEUS_NAMESPACE := monitoring
REDIS_RELEASE_NAME := redis
PROMETHEUS_RELEASE_NAME := prometheus
REDIS_VALUES_FILE := redis-values.yaml
PROMETHEUS_VALUES_FILE := prometheus-values.yaml

# Phony targets are not files
.PHONY: all setup redis-install prometheus-install redis-upgrade-monitoring redis-scale redis-login prometheus-ui clean

# Default target: runs all steps in order
all: setup redis-install prometheus-install redis-upgrade-monitoring

# Setup: Creates namespaces and adds Helm repositories
setup:
	@echo "--- Setting up namespaces and Helm repos ---"
	kubectl create namespace $(REDIS_NAMESPACE) || true
	kubectl create namespace $(PROMETHEUS_NAMESPACE) || true
	helm repo add bitnami https://charts.bitnami.com/bitnami
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm repo update

# Install Redis with monitoring initially disabled
redis-install:
	@echo "--- Installing Redis HA Cluster ---"
	@echo "Note: ServiceMonitor is initially disabled. It will be enabled after Prometheus is installed."
	helm install $(REDIS_RELEASE_NAME) bitnami/redis \
		--namespace $(REDIS_NAMESPACE) \
		-f $(REDIS_VALUES_FILE) \
		--set replica.replicaCount=3 \
		--set metrics.serviceMonitor.enabled=false

# Install the Prometheus monitoring stack
prometheus-install:
	@echo "--- Installing Kube Prometheus Stack ---"
	helm install $(PROMETHEUS_RELEASE_NAME) prometheus-community/kube-prometheus-stack \
		--namespace $(PROMETHEUS_NAMESPACE) \
		-f $(PROMETHEUS_VALUES_FILE)

# Upgrade Redis to enable the ServiceMonitor for Prometheus
redis-upgrade-monitoring:
	@echo "--- Upgrading Redis to enable Prometheus ServiceMonitor ---"
	helm upgrade $(REDIS_RELEASE_NAME) bitnami/redis \
		--namespace $(REDIS_NAMESPACE) \
		-f $(REDIS_VALUES_FILE) \
		--set replica.replicaCount=3 \
		--set metrics.serviceMonitor.enabled=true

# --- Utility Targets ---

# Manually scale the Redis statefulset if needed
redis-scale:
	@echo "--- Scaling Redis StatefulSet to 3 replicas ---"
	kubectl scale statefulset $(REDIS_RELEASE_NAME)-node --replicas=3 -n $(REDIS_NAMESPACE)

# Log into the Redis master pod
redis-login:
	@echo "--- Logging into Redis master pod ---"
	kubectl exec -it $(REDIS_RELEASE_NAME)-node-0 -n $(REDIS_NAMESPACE) -- redis-cli -a $$(kubectl get secret --namespace $(REDIS_NAMESPACE) $(REDIS_RELEASE_NAME) -o jsonpath="{.data.redis-password}" | base64 --decode)

# Port-forward the Prometheus UI to localhost:9090
prometheus-ui:
	@echo "--- Port-forwarding Prometheus UI to http://localhost:9090 ---"
	kubectl port-forward svc/$(PROMETHEUS_RELEASE_NAME)-operated -n $(PROMETHEUS_NAMESPACE) 9090:9090

# Clean up all resources
clean:
	@echo "--- Deleting Helm releases and namespaces ---"
	helm uninstall $(REDIS_RELEASE_NAME) -n $(REDIS_NAMESPACE) || true
	helm uninstall $(PROMETHEUS_RELEASE_NAME) -n $(PROMETHEUS_NAMESPACE) || true
	kubectl delete namespace $(REDIS_NAMESPACE) || true
	kubectl delete namespace $(PROMETHEUS_NAMESPACE) || true


