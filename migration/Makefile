IMAGE ?= vddk
NAMESPACE ?= openshift-mtv
REGISTRY ?= default-route-openshift-image-registry.apps.hub.lab.bewley.net
REGISTRY_USER ?= dlbewley
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
	podman build . -t $(IMAGE):$(VDDK_VER) && \
	podman tag $(IMAGE):$(VDDK_VER) $(REGISTRY)/$(NAMESPACE)/$(IMAGE):$(VDDK_VER) && \
	podman tag $(IMAGE):$(VDDK_VER) $(REGISTRY)/$(NAMESPACE)/$(IMAGE):latest

login:
	podman login -u $(REGISTRY_USER) -p $(TOKEN) $(REGISTRY)

push:
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
