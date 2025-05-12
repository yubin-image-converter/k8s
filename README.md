# k8s

argocd login argocd.yubinshin.com --username admin --password ieuLQ4eVe4IYsXGW%

argocd app sync api-dev
argocd app sync auth-dev
argocd app sync frontend-dev
argocd app sync websocket-dev
argocd app sync worker-dev
argocd app sync rabbitmq-dev

chmod +x ./scripts/seal-all-secrets.sh
./scripts/seal-all-secrets.sh

kubeseal \
 --cert ./pub-cert.pem \
 --format yaml \
 --name fe-secret-dev \
 --namespace image-converter \
 < apps/frontend/overlays/dev/secret.yaml \

> apps/frontend/overlays/dev/sealed-secret.yaml
