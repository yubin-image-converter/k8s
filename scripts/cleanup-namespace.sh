#!/bin/bash

echo "🧼 모든 리소스 파일에서 namespace 필드를 제거 중..."

find ./apps -type f \( -name "*.yaml" -o -name "*.yml" \) | while read -r file; do
  if grep -q "namespace:" "$file"; then
    echo "✂️  removing 'namespace:' from $file"
    # namespace 줄 삭제
    sed -i '' '/^[[:space:]]*namespace:/d' "$file"
  fi
done

echo "✅ 완료! 이제 namespace는 overlays의 kustomization.yaml에서만 설정하면 돼요 🎉"
