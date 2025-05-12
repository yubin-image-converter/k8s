#!/bin/bash

set -euo pipefail

# 기본 설정
CERT_PATH="./pub-cert.pem"
OVERLAY_DIRS=$(find ./apps -type d -path "*/overlays/dev")

# pub-cert.pem 유효성 체크
if [ ! -f "$CERT_PATH" ]; then
  echo "❌ $CERT_PATH 가 존재하지 않습니다. 먼저 cert-manager에서 추출하세요."
  exit 1
fi

echo "🔐 Sealing all secrets using $CERT_PATH..."

for dir in $OVERLAY_DIRS; do
  SECRET="$dir/secret.yaml"
  SEALED_SECRET="$dir/sealed-secret.yaml"

  if [ ! -f "$SECRET" ]; then
    echo "⚠️  $SECRET 가 존재하지 않아 스킵합니다."
    continue
  fi

  echo "✅ Sealing $SECRET → $SEALED_SECRET"

  kubeseal \
    --format yaml \
    --cert "$CERT_PATH" \
    < "$SECRET" \
    > "$SEALED_SECRET"
done

echo "🎉 모든 secret이 sealed 되었습니다!"
