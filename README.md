# k8s

argocd login argocd.yubinshin.com --username admin --password ieuLQ4eVe4IYsXGW

argocd app sync api-dev
argocd app sync auth-dev
argocd app sync frontend-dev
argocd app sync websocket-dev
argocd app sync worker-dev
argocd app sync rabbitmq-dev
argocd app sync infrastructure

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

kubectl get pods -A
kubectl describe pod api-server-cb9b59f7-qm585 -n image-converter
kubectl logs api-server-cb9b59f7-qm585 -n image-converter
kubectl logs worker-65c5c94cc6-7ksmw -n image-converter
kubectl describe pod worker-65c5c94cc6-7ksmw -n image-converter

kubectl get pod -n image-converter -o wide | grep worker
kubectl describe pod worker-5656f46c84-kx52s -n image-converter | grep Image

image-converter rabbitmq-7966569bcd-2b6xv 1/1 Running 0 13h
image-converter worker-5656f46c84-kx52s 0/1 CrashLoopBackOff 10 (97s ago) 13h

docker inspect shinyubin/image-converter-worker:latest | grep -i sha256

        "Id": "sha256:60d44455fd267947fd41331c66a8f6a7eb3ce97542e2042237e638e327439941",
            "shinyubin/image-converter-worker@sha256:00138374f56de1d0d7e357a00e03ab2fde9ac2947fc3554c06fa8251b4ac2c8f"
                "sha256:0499fc56f5e2303d8f36d9dd1908d469f446b41e0af05a98a5bcdbcecc799a43",
                "sha256:d38857fc559cfc64ecf4317303e364c97f42b3f2cec09b2fbccaea607924c22d"

# Pod 이름 자동으로 가져와서 로그 보기 (예: worker)

kubectl logs -f $(kubectl get pod -l app=api -n image-converter -o name) -n image-converter
kubectl logs -f $(kubectl get pod -l app=auth -n image-converter -o name) -n image-converter
kubectl logs -f $(kubectl get pod -l app=frontend -n image-converter -o name) -n image-converter
kubectl logs -f $(kubectl get pod -l app=websocket -n image-converter -o name) -n image-converter
kubectl logs -f $(kubectl get pod -l app=worker -n image-converter -o name) -n image-converter

kubectl logs -f -l app=api-server -n image-converter
kubectl logs -f -l app=auth-server -n image-converter
kubectl logs -f -l app=frontend-server -n image-converter

kubectl logs -f -l app=websocket -n image-converter
kubectl logs -f -l app=worker -n image-converter

gcloud container clusters resize image-converter-cluster \
 --node-pool=default-pool \
 --num-nodes=3 \
 --zone=asia-northeast3-a

gcloud compute instances list

frontend-server-6858479bd6-cr9r9

kubectl logs -f -l app=websocket-server -n image-converter
