#!/bin/bash

#Create the ArgoCD Root App
kubectl apply -f - <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: root-app
  namespace: argocd
spec:
  destination:
    namespace: argocd
    server: 'https://kubernetes.default.svc'
  source:
    path: root
    repoURL: 'https://github.com/ams0/multicluster-capz-argo.git'
    targetRevision: HEAD
    directory:
      recurse: true
  project: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
EOF