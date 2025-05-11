#!/bin/bash

CLUSTER_DIR="clusters/image-converter/apps"
mkdir -p "$CLUSTER_DIR"

echo "📦 clusters/image-converter/apps 디렉토리 생성 중..."

for SERVICE in $(ls apps); do
  OVERLAY_DIR="apps/$SERVICE/overlays/dev"
  if [ -d "$OVERLAY_DIR" ]; then
    TARGET="$CLUSTER_DIR/$SERVICE-dev.yaml"
    echo "🧩 $SERVICE → dev overlay 감지됨, $TARGET 생성"

    cat <<EOF > "$TARGET"
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ../../../apps/$SERVICE/overlays/dev
EOF
  else
    echo "⚠️ $SERVICE 는 dev overlay가 없어서 스킵!"
  fi
done

echo "✅ clusters/image-converter/apps/*.yaml 스캐폴딩 완료!"
