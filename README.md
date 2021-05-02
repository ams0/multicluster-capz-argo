# Multicluster GitOps with ArgoCD and ClusterAPI for Azure

This repo serves as a companion to the talk at [GitOpsCon 2021](https://hopin.com/events/gitops-con) "Managing multiple clusters with GitOps and ClusterAPI" organized by the [CNCF GitOps Working Group](https://github.com/gitops-working-group/gitops-working-group), a pre-day event for KubeconEU 2021.

It leverages the new [ApplicationSet](https://argoproj.github.io/argo-cd/user-guide/application-set/) controller for ArgoCD to scan a folder with cluster definitions and creates an Application per cluster, calling the chart in [`charts/azure-managed-cluster`](charts/azure-managed-cluster) to deploy an AKS cluster with ClusterAPI for Azure controller.

## Walkthrough

1. Fork this repo and `sed` your github username for mine:

```bash
sed -i 
```

2. Install an AKS cluster with ArgoCD, ingress-nginx, cert-manager.

```bash
cd 01-setup
./seed-setup.sh
```

3. Install ClusterAPI with Azure provider (edit the script if you don't have the environment variables: AZURE_SUBSCRIPTION_ID, AZURE_TENANT_ID, AZURE_CLIENT_ID and AZURE_CLIENT_SECRET set to a service principal with enough rights to create AKS clusters in your subscription.)

```bash
./02-capz-setup.sh
```

4. Install the root 