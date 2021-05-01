# Multicluster GitOps with ArgoCD and ClusterAPI for Azure

This repo serves as a companion to the talk at [GitOpsCon 2021](https://hopin.com/events/gitops-con) "Managing multiple clusters with GitOps and ClusterAPI" organized by the [CNCF GitOps Working Group](https://github.com/gitops-working-group/gitops-working-group), a pre-day event for KubeconEU 2021.

## Walkthrough

1. Install an AKS cluster with ArgoCD, ingress-nginx, cert-manager.

```bash
cd 01-setup
./seed-setup.sh
```

1. Install ClusterAPI with Azure provider (edit the script if you don't have the environtment variable set)

```bash
./capz-setup.sh
```