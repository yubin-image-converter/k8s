#!/bin/bash
set -euo pipefail

CERT_PATH="./pub-cert.pem"
OVERLAY_DIRS=$(find ./apps -type d -path "*/overlays/dev")

if [ ! -f "$CERT_PATH" ]; then
  echo "❌ $CERT_PATH 가 존재하지 않습니다. 먼저 sealed-secrets에서 추출하세요."
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

  NAME=$(grep '^  name:' "$SECRET" | head -n1 | awk '{print $2}')
  NAMESPACE=$(grep '^  namespace:' "$SECRET" | head -n1 | awk '{print $2}')

  if [ -z "$NAME" ] || [ -z "$NAMESPACE" ]; then
    echo "❌ $SECRET 에서 name 또는 namespace 추출 실패. 스킵합니다."
    continue
  fi

  if [ -f "$SEALED_SECRET" ]; then
    echo "🧹 이전 sealed-secret 삭제: $SEALED_SECRET"
    rm -f "$SEALED_SECRET"
  fi

  echo "✅ Sealing $SECRET → $SEALED_SECRET (name=$NAME, namespace=$NAMESPACE)"

  kubeseal \
    --format yaml \
    --cert "$CERT_PATH" \
    --name "$NAME" \
    --namespace "$NAMESPACE" \
    < "$SECRET" \
    > "$SEALED_SECRET"

  # 🔁 이름 덮어쓰기 (metadata.name & spec.template.metadata.name)
  sed -i '' "s/name: .*/name: $NAME/" "$SEALED_SECRET"

  git add "$SEALED_SECRET"
done

echo "🎉 모든 sealed-secret이 재생성 및 Git stage 완료되었습니다!"
