#!/bin/bash
set -euo pipefail

# 1. Argo CD 설치
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# 2. Sealed Secrets 설치 (Helm)
helm repo add sealed-secrets https://bitnami-labs.github.io/sealed-secrets
helm repo update
helm upgrade --install sealed-secrets-controller sealed-secrets/sealed-secrets \
  --namespace kube-system --create-namespace

# 3. 공개키(pub-cert.pem) 추출
kubectl wait --namespace kube-system --for=condition=available --timeout=60s deployment/sealed-secrets-controller
kubectl get secret -n kube-system -l sealedsecrets.bitnami.com/sealed-secrets-key \
  -o jsonpath="{.items[0].data['tls\.crt']}" | base64 -d > pub-cert.pem

# 4. cert-manager 설치
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm upgrade --install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set installCRDs=true
kubectl apply -f infrastructures/cert-manager/cluster-issuer.yaml

# 5. ingress-nginx 설치 (고정 IP 지정)
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  --set controller.service.loadBalancerIP=34.64.151.153

# 6. infrastructure 리소스 배포
kubectl apply -k infrastructures

# Argo CD 초기 비밀번호 출력
echo "Argo CD 초기 비밀번호:"
kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 -d && echo

# 완료
echo "클러스터 부트스트랩 완료!"
