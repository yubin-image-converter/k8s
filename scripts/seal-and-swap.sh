#!/bin/bash
set -euo pipefail

# [1] 대상 디렉토리 지정 (예: apps/api/overlays/dev)
TARGET_DIR="$1"

PLAIN_SECRET="$TARGET_DIR/secret.yaml"
SEALED_SECRET="$TARGET_DIR/sealed-secret.yaml"
KUSTOMIZATION="$TARGET_DIR/kustomization.yaml"

if [[ ! -f "$PLAIN_SECRET" ]]; then
  echo "❌ plain secret 파일이 없습니다: $PLAIN_SECRET"
  exit 1
fi

if [[ ! -f pub-cert.pem ]]; then
  echo "❌ pub-cert.pem이 없습니다. bootstrap-cluster.sh 실행 후 다시 시도하세요."
  exit 1
fi

echo "🔐 Sealing $PLAIN_SECRET → $SEALED_SECRET ..."
kubeseal --cert pub-cert.pem --format yaml < "$PLAIN_SECRET" > "$SEALED_SECRET"

echo "✏️ kustomization.yaml 수정 중..."
# secret.yaml 줄 제거하고 sealed-secret.yaml 추가 (존재하지 않으면 맨 아래에 추가)
sed -i.bak '/secret.yaml/d' "$KUSTOMIZATION"
if ! grep -q "sealed-secret.yaml" "$KUSTOMIZATION"; then
  echo "  - sealed-secret.yaml" >> "$KUSTOMIZATION"
fi

echo "📁 .gitignore에 secret.yaml 추가 권장: $PLAIN_SECRET"
echo "✅ 완료!"
