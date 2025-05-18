#!/bin/bash
set -euo pipefail

STATIC_INGRESS_IP="34.64.151.153"

echo "🧠 [1] Argo CD 설치 중..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "🔐 [2] Sealed Secrets 설치 중..."
kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.25.0/controller.yaml

echo "📥 [3] Sealed Secrets 공개키 저장 중..."
kubectl wait --namespace kube-system --for=condition=available --timeout=60s deployment/sealed-secrets-controller
kubectl get secret -n kube-system -l sealedsecrets.bitnami.com/sealed-secrets-key \
  -o jsonpath="{.items[0].data['tls\.crt']}" | base64 -d > pub-cert.pem

if [[ "${SKIP_CERT_MANAGER:-false}" != "true" ]]; then
  echo "📦 [4] cert-manager 설치 중..."
  kubectl apply -k infrastructures/cert-manager
  kubectl apply -f infrastructures/cert-manager/cluster-issuer.yaml
fi

echo "🌐 [5] ingress-nginx 설치 중 (고정 IP: $STATIC_INGRESS_IP)..."
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  --set controller.service.loadBalancerIP=$STATIC_INGRESS_IP

echo "🏗️ [6] infrastructures/base 적용 중..."
kubectl apply -k infrastructures/base

echo "📡 [7] Argo CD Ingress 설정 적용 중..."
kubectl apply -k infrastructures/argocd

echo "✅ 클러스터 부트스트랩 완료!"
