#!/bin/bash

set -euo pipefail

# 설정
CERT_PATH="./pub-cert.pem"
OVERLAY_DIRS=$(find ./apps -type d -path "*/overlays/dev")

# pub-cert.pem 체크
if [ ! -f "$CERT_PATH" ]; then
  echo "❌ $CERT_PATH 가 존재하지 않습니다. 먼저 sealed-secrets에서 추출하세요."
  exit 1
fi

echo "🔐 Sealing all secrets using $CERT_PATH..."

for dir in $OVERLAY_DIRS; do
  SECRET="$dir/secret.yaml"
  SEALED_SECRET="$dir/sealed-secret.yaml"

  if [ ! -f "$SECRET" ]; then
    echo "⚠️  $SECRET 가 존재하지 않아 스탭합니다."
    continue
  fi

  # sealed-secret name = overlays/dev 디렉토리명 + -secret
  APP_NAME=$(basename $(dirname "$dir")) # 예: api, auth...
  NAME="$APP_NAME-secret-dev"

  # namespace 추출
  NAMESPACE=$(grep '^  namespace:' "$SECRET" | head -n1 | awk '{print $2}')

  if [ -z "$NAME" ] || [ -z "$NAMESPACE" ]; then
    echo "❌ $SECRET 에서 name 또는 namespace 추출 실패. 스탭합니다."
    continue
  fi

  # sealed-secret.yaml 삭제
  if [ -f "$SEALED_SECRET" ]; then
    echo "🧹 이전 sealed-secret 삭제: $SEALED_SECRET"
    rm -f "$SEALED_SECRET"
  fi

  # 생성
  echo "✅ Sealing $SECRET → $SEALED_SECRET (name=$NAME, namespace=$NAMESPACE)"

  kubeseal \
    --format yaml \
    --cert "$CERT_PATH" \
    --name "$NAME" \
    --namespace "$NAMESPACE" \
    < "$SECRET" > "$SEALED_SECRET"

  # Git add
  git add "$SEALED_SECRET"
done

echo "🎉 모든 sealed-secret이 재생성 및 Git stage 완료되었습니다!"
