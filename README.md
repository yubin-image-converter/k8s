# k8s

argocd login argocd.yubinshin.com --username admin --password ieuLQ4eVe4IYsXGW

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
 --name api-secret \
 --namespace image-converter \
 < apps/api/overlays/dev/secret.yaml \

> apps/api/overlays/dev/sealed-secret.yaml

kubeseal \
 --cert ./pub-cert.pem \
 --format yaml \
 --name auth-secret \
 --namespace image-converter \
 < apps/auth/overlays/dev/secret.yaml \

> apps/auth/overlays/dev/sealed-secret.yaml

kubeseal \
 --cert ./pub-cert.pem \
 --format yaml \
 --name fe-secret \
 --namespace image-converter \
 < apps/frontend/overlays/dev/secret.yaml \

> apps/frontend/overlays/dev/sealed-secret.yaml

kubeseal \
 --cert ./pub-cert.pem \
 --format yaml \
 --name rabbitmq-secret \
 --namespace image-converter \
 < apps/rabbitmq/overlays/dev/secret.yaml \

> apps/rabbitmq/overlays/dev/sealed-secret.yaml

kubeseal \
 --cert ./pub-cert.pem \
 --format yaml \
 --name websocket-secret \
 --namespace image-converter \
 < apps/websocket/overlays/dev/secret.yaml \

> apps/websocket/overlays/dev/sealed-secret.yaml

kubeseal \
 --cert ./pub-cert.pem \
 --format yaml \
 --name worker-secret \
 --namespace image-converter \
 < apps/worker/overlays/dev/secret.yaml \

> apps/worker/overlays/dev/sealed-secret.yaml
