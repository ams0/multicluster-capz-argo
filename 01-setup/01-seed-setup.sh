#!/bin/bash

EMAIL=alessandro.vozza@microsoft.com
URL="${1:-capz}"
LOCATION="${2:-westeurope}"

# Needs a logged in azure cli and the `aks-preview` extension.

az group create -n seed
az aks create -k 1.20.5 -g seed \
--network-policy calico --network-plugin kubenet \
-c 2 -s Standard_B2ms --enable-managed-identity \
-l westeurope -n seed

az aks get-credentials -g seed -n seed --overwrite-existing

#install argocd 
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj-labs/applicationset/v0.1.0/manifests/install.yaml

#install cert-manager & cluster-issuer
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.3.1/cert-manager.yaml
kubectl wait --timeout=600s --for condition=Ready -n cert-manager po -l app.kubernetes.io/component=controller
kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1alpha2
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    email: $EMAIL
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencrypt-prod-issuer-account-key
    solvers:
    - http01:
        ingress:
          class: nginx
EOF

#install ingress & setup external IP to capz.westeurope.cloudapp.azure.com
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.46.0/deploy/static/provider/cloud/deploy.yaml
kubectl wait --timeout=600s --for condition=Ready -n ingress-nginx po -l app.kubernetes.io/component=controller
kubectl annotate -n ingress-nginx svc ingress-nginx-controller "service.beta.kubernetes.io/azure-dns-label-name=$URL"

#ArgoCD ingress setup
kubectl apply -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd-server-ingress
  namespace: argocd
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
    kubernetes.io/ingress.class: nginx
    kubernetes.io/tls-acme: "true"
    nginx.ingress.kubernetes.io/ssl-passthrough: "true"
    # If you encounter a redirect loop or are getting a 307 response code 
    # then you need to force the nginx ingress to connect to the backend using HTTPS.
    #
    nginx.ingress.kubernetes.io/backend-protocol: "HTTPS"
spec:
  rules:
  - host: $URL.$LOCATION.cloudapp.azure.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service: 
            name: argocd-server
            port:
              name: https
  tls:
  - hosts:
    - $URL.$LOCATION.cloudapp.azure.com
    secretName: argocd-secret # do not change, this is provided by Argo CD
EOF

#Change default password for ArgoCD
kubectl -n argocd patch secret argocd-secret \
  -p '{"stringData": {
    "admin.password": "$2a$10$dAhSI0FMGomk0ve0Najj2ucAlV9FYVxTjkV9TRTC5HnqpEHxjK3FC",
    "admin.passwordMtime": "'$(date +%FT%T%Z)'"
  }}'

#Open the ArgoCD login page (admin/supersecret)
open https://$URL.$LOCATION.cloudapp.azure.com


