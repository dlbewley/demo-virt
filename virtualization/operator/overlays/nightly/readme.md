# OpenShift Virtualization Nightly Build

Docs

* [Installing pre-release versions of OpenShift Virtualization (CNV) - Red Hat Customer](https://access.redhat.com/articles/6070641)
  * Employees, just go here to request access https://cnv-quay-inviter.apps.cnv2.engineering.redhat.com/
* For NMstate and other operators see also [Using Pre-release Operators](https://art-docs.engineering.redhat.com/olm-bundles/#using-pre-released-operators)

Update global pull secret for `quay.io/openshift-cnv` per the [KCS](https://access.redhat.com/articles/6070641)

Update version in the [catalogsource](catalogsource.yaml)

Update version in the [subscription](patch-subscription.yaml)

```bash
oc apply -k virtualization/operator/overlays/nightly
oc apply -k virtualization/instance/base
```
