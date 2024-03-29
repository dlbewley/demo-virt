IMAGE ?= vddk
NAMESPACE ?= openshift-mtv
APPS_DOMAIN ?= apps.hub.lab.bewley.net
REGISTRY ?= default-route-openshift-image-registry.$(APPS_DOMAIN)
REGISTRY_USER ?= builder
# openshift token (oc whoami -t)
TOKEN ?= sha256~EXAMPLE
TLS_VERIFY ?= false
VDDK_VER ?= 7.0.3-20134304
VDDK_ARCHIVE ?= VMware-vix-disklib-$(VDDK_VER).x86_64.tar.gz

.PHONY: p-*

showconfig: p-IMAGE p-NAMESPACE p-REGISTRY p-REGISTRY_USER p-VDDK_ARCHIVE p-VDDK_VER 

p-%:
	@echo '$*=$(subst ','\'',$(subst $(newline),\n,$($*)))'

image: unarchive
	podman build . --label VDDK_VER=$(VDDK_VER) -t $(IMAGE):$(VDDK_VER) && \
	podman tag $(IMAGE):$(VDDK_VER) $(REGISTRY)/$(NAMESPACE)/$(IMAGE):$(VDDK_VER) && \
	podman tag $(IMAGE):$(VDDK_VER) $(REGISTRY)/$(NAMESPACE)/$(IMAGE):latest

login:
	podman login --tls-verify=$(TLS_VERIFY) -u $(REGISTRY_USER) -p $(TOKEN) $(REGISTRY)

push:
	podman push --tls-verify=$(TLS_VERIFY) $(REGISTRY)/$(NAMESPACE)/$(IMAGE):$(VDDK_VER) && \
	podman push --tls-verify=$(TLS_VERIFY) $(REGISTRY)/$(NAMESPACE)/$(IMAGE):latest

unarchive: vmware-vix-disklib-distrib

vmware-vix-disklib-distrib:
	tar -xzf $(VDDK_ARCHIVE)

clean:
	rm -rf vmware-vix-disklib-distrib

realclean: clean
	podman rmi \
	$(IMAGE):$(VDDK_VER) \
	$(REGISTRY)/$(NAMESPACE)/$(IMAGE):$(VDDK_VER) \
	$(REGISTRY)/$(NAMESPACE)/$(IMAGE):latest
