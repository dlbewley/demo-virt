[Installing pre-release versions of OpenShift Virtualization (CNV) - Red Hat Customer](https://access.redhat.com/articles/6070641)
Internal https://docs.google.com/document/d/1oyvJncbhjUr7XBFrNsNlviZJEbCXay7tSwe4fCedfD4/edit?tab=t.0

Fill in the referenced Google form requesting that your Quay.io login be granted access to CNV images.

May seek help from danken@redhat.com for accessing quay.

https://cnv-quay-inviter.apps.cnv2.engineering.redhat.com/
new versions https://amd64.ocp.releases.ci.openshift.org/releasestream/4.18.0-0.nightly/release/4.18.0-0.nightly-2024-11-21-131835  registry.ci.openshift.org/ocp/release:4.18.0-0.nightly-2024-11-21-131835

Then 

Patch

oc adm upgrade --force --allow-explicit-upgrade --to-image=quay.io/openshift-release-dev/ocp-release:4.18.0-ec.4-multi

```bash

$ QUAY_USERNAME=<your quay.io username>
$ QUAY_PASSWORD=<the encrypted password generated in step #3>
Fetch the current pull-secret data:
$ oc get secret pull-secret -n openshift-config -o json | jq -r '.data.".dockerconfigjson"' | base64 -d > global-pull-secret.json

#Encode the username and password in base64 to comply with the auth format in the pull-secret:
$ QUAY_AUTH=$(echo -n "${QUAY_USERNAME}:${QUAY_PASSWORD}" | base64 -w 0)
```


* Add CNV nightly catalog source

```bash
$ CNV_VERSION=4.18
$ cat <<EOF | oc apply -f -
apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: cnv-nightly-catalog-source
  namespace: openshift-marketplace
spec:
  sourceType: grpc
  image: quay.io/openshift-cnv/nightly-catalog:${CNV_VERSION}
  displayName: OpenShift Virtualization Nightly Index
  publisher: Red Hat
  updateStrategy:
    registryPoll:
      interval: 8h
EOF
```

* Confirm kubevirt-hyperconverged package appears in:

```bash
$ oc get packagemanifest -l catalog=cnv-nightly-catalog-source -n openshift-cnv
```

* Install CNV Nightly

```bash
$ CNV_VERSION=4.18
$ STARTING_CSV=$(oc get packagemanifest -l catalog=cnv-nightly-catalog-source \
  -o jsonpath="{$.items[?(@.metadata.name=='kubevirt-hyperconverged')].status.channels[?(@.name==\"nightly-${CNV_VERSION}\")].currentCSV}")

$ cat <<EOF | oc apply -f -
apiVersion: v1
kind: Namespace
metadata:
    name: openshift-cnv
---
apiVersion: operators.coreos.com/v1
kind: OperatorGroup
metadata:
    name: kubevirt-hyperconverged-group
    namespace: openshift-cnv
spec:
    targetNamespaces:
    - openshift-cnv
---
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
    name: hco-operatorhub
    namespace: openshift-cnv
spec:
    source: cnv-nightly-catalog-source
    sourceNamespace: openshift-marketplace
    name: kubevirt-hyperconverged
    startingCSV: ${STARTING_CSV}
    channel: "nightly-${CNV_VERSION}"
EOF
```

* Setup CNV

```bash
$ cat <<EOF | oc apply -f - 
apiVersion: hco.kubevirt.io/v1beta1
kind: HyperConverged
metadata:
    name: kubevirt-hyperconverged
    namespace: openshift-cnv
spec: {}
EOF
```
