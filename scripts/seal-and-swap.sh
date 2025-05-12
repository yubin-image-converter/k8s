#!/bin/bash
set -e

TARGET_DIR="$1"

PLAIN_SECRET="$TARGET_DIR/secret.yaml"
SEALED_SECRET="$TARGET_DIR/sealed-secret.yaml"
KUSTOMIZATION="$TARGET_DIR/kustomization.yaml"
PUB_CERT="pub-cert.pem"

# 1. pub-cert.pem 없으면 자동으로 클러스터에서 받아오기
if [[ ! -f "$PUB_CERT" ]]; then
  echo "📥 pub-cert.pem not found. Fetching from cluster..."
  kubeseal --fetch-cert \
    --controller-name sealed-secrets-controller \
    --controller-namespace kube-system > "$PUB_CERT"
fi

# 2. plain secret 없으면 종료
if [[ ! -f "$PLAIN_SECRET" ]]; then
  echo "❌ $PLAIN_SECRET not found. Aborting."
  exit 1
fi

# 3. seal
echo "🔐 Sealing $PLAIN_SECRET → $SEALED_SECRET ..."
kubeseal --cert "$PUB_CERT" --format yaml \
  < "$PLAIN_SECRET" > "$SEALED_SECRET"

# 4. sealed-secret.yaml이 없으면 추가
grep -q "sealed-secret.yaml" "$KUSTOMIZATION" \
  || echo "  - sealed-secret.yaml" >> "$KUSTOMIZATION"

# 5. secret.yaml 줄 제거
sed -i.bak '/secret.yaml/d' "$KUSTOMIZATION"

echo "✅ Done! Sealed and updated $KUSTOMIZATION"
