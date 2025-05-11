#!/bin/bash

SERVICE_NAME=$1

if [ -z "$SERVICE_NAME" ]; then
  echo "❗ 서비스 이름을 인자로 넣어주세요!"
  echo "예: ./scaffold-kustomize.sh api"
  exit 1
fi

ROOT_DIR="apps/$SERVICE_NAME"
BASE_DIR="$ROOT_DIR/base"
OVERLAYS_DIR="$ROOT_DIR/overlays/dev"

echo "📁 $SERVICE_NAME 디렉토리 스캐폴딩 중..."

mkdir -p "$BASE_DIR"
mkdir -p "$OVERLAYS_DIR"

# base 리소스 이름들
FILES=(deployment.yaml service.yaml cm.yaml secret.yaml namespace.yaml)

for FILE in "${FILES[@]}"; do
  if [ -f "$ROOT_DIR/$FILE" ]; then
    echo "📦 기존 $FILE 발견 → base/로 이동"
    mv "$ROOT_DIR/$FILE" "$BASE_DIR/$FILE"
  else
    echo "🆕 $FILE 없음 → 빈 파일 생성"
    touch "$BASE_DIR/$FILE"
  fi
done

# kustomization.yaml 생성
cat <<EOF > $BASE_DIR/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

namespace: $SERVICE_NAME
resources:
  - namespace.yaml
  - deployment.yaml
  - service.yaml
  - cm.yaml
  - secret.yaml
EOF

# overlays/dev 생성
cat <<EOF > $OVERLAYS_DIR/kustomization.yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization

resources:
  - ../../base

nameSuffix: -dev
EOF

echo "✅ $SERVICE_NAME 스캐폴딩 완료!"
