# Multicluster GitOps with ArgoCD and ClusterAPI for Azure

This repo serves as a companion to the talk at [GitOpsCon 2021](https://hopin.com/events/gitops-con) "Managing multiple clusters with GitOps and ClusterAPI" organized by the [CNCF GitOps Working Group](https://github.com/gitops-working-group/gitops-working-group), a pre-day event for KubeconEU 2021.

It leverages the new [ApplicationSet](https://argoproj.github.io/argo-cd/user-guide/application-set/) controller for ArgoCD to scan a folder with cluster definitions and creates an Application per cluster, calling the chart in [`charts/azure-managed-cluster`](charts/azure-managed-cluster) to deploy an AKS cluster with ClusterAPI for Azure controller.

## Walkthrough

1. Fork this repo and `sed` your github username for mine:

```bash
 sed -i 's/ams0/youruser/' root/clusters-appset.yaml
 ```

2. Install an AKS cluster with ArgoCD with ApplicationSet controller, ingress-nginx, cert-manager. The <URL> is the name before `.LOCATIOn.cloudapp.azure.com` 

```bash
cd 01-setup
./seed-setup.sh <URL> <LOCATION>
```

3. Install ClusterAPI with Azure provider (edit the script if you don't have the environment variables: AZURE_SUBSCRIPTION_ID, AZURE_TENANT_ID, AZURE_CLIENT_ID and AZURE_CLIENT_SECRET set to a service principal with enough rights to create AKS clusters in your subscription.)

```bash
./02-capz-setup.sh
```

4. Install the root app

```bash
./03-rootapp.sh
```

The root app will pull the manifests from the `root` folder in your forked repo, applying the `ApplicationSet` ArgoCD which in turn will create clusters according to the manifests present in the `clusters` folder (create a subfolder per cluster, named after the desired cluster name).

5. Once you have a workload cluster, login in ArgoCD and add the workload cluster:

```bash
argocd login $URL.$LOCATION.cloudapp.azure.com:443 --username admin --password supersecret --grpc-web
```

Get the kubeconfig and add it to ArgoCD context

```bash
kubectl get secret -n clusters aks3-kubeconfig -o yaml -o jsonpath={.data.value} | base64 --decode | tee aks3.kubeconfig

argocd cluster add aks3 --name aks3 --kubeconfig aks3.kubeconfig
rm aks3.kubeconfig
```