#AUTOGENERATED. Never modify manually
#it is generated from the configuration template : deploy.make.template and script : helm_chart_mapper.py
.ONESHELL:
MAKEFLAGS += --warn-undefined-variables
# -------------------------------------------------------
# -- ENV section
# -------------------------------------------------------
ENV ?= local
SERVICES = data-team-bootstrap
HELM_CHART_NAME = data-team-bootstrap
deploy: setk8scontext
	for service in $(SERVICES); do \
		helm tiller run $(NAMESPACE) -- helm upgrade --install --wait "$$service" $(HELM_CHART_NAME)-helm --values ./helm-values/$$service-helm-values/values-$(ENV).yaml
	done
undeploy: setk8scontext
	for service in $(SERVICES); do \
		helm tiller run $(NAMESPACE) -- helm del $$service --purge
	done
setk8scontext:
ifeq ($(ENV), local)
	@kubectl config use-context minikube
else
	@kubectl config set-cluster default --server=$(KUBERNETES_SERVER)
	@kubectl config set-credentials default-user --token=$(KUBE_TOKEN)
	@kubectl config set-context default --cluster=default --user=default-user --namespace=$(NAMESPACE)
	@kubectl config use-context default
endif
rollback: setk8scontext
	for service in $(SERVICES); do \
		helm tiller run $(NAMESPACE) -- helm rollback $$service 0
	done
.PHONY: deploy undeploy rollback