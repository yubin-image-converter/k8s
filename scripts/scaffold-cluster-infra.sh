#!/bin/bash

SRC_DIR="infrastructures"
DEST_DIR="clusters/image-converter/infrastructure"

mkdir -p "$DEST_DIR"

echo "🔧 infrastructures → clusters/image-converter/infrastructure 복사 중..."

for COMPONENT in $(ls $SRC_DIR); do
  if [ -d "$SRC_DIR/$COMPONENT" ]; then
    TARGET="$DEST_DIR/$COMPONENT.yaml"
    echo "🧱 $COMPONENT → $TARGET 생성"

    cat <<EOF > "$TARGET"
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - ../../../infrastructures/$COMPONENT
EOF
  fi
done

echo "✅ infrastructure 스캐폴딩 완료!"
