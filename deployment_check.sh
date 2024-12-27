#!/bin/bash
# deployment_check.sh

current_hash=$(find "$user_id/templates" "$user_id/values.yaml" -type f -exec sha256sum {} \; | sort | sha256sum | awk '{print $1}')
hash_file="$user_id/.last_deploy_hash"

if [[ -f "$hash_file" ]]; then
  previous_hash=$(cat "$hash_file")
else
  previous_hash=""
fi

if [[ "$current_hash" == "$previous_hash" ]]; then
  echo "🔄 [$user_id]에는 변경된 내용이 없습니다. 배포를 건너뜁니다."
else
  echo "✨ [$user_id]에 변경사항이 감지되었습니다. Helm 배포를 진행합니다."
  if helm upgrade --install "$user_id-helm" "./$user_id" --namespace "web-$user_id" --create-namespace; then
    echo "$(date): 🟢 [$user_id] | 애플리케이션: [$app] | 버전: [$ver] 배포가 성공적으로 완료되었습니다." >> deployment.log
    echo "✅ [$user_id]의 Helm 배포가 완료되었습니다."
    echo "$current_hash" > "$hash_file"
  else
    echo "$(date): 🔴 [$user_id] | 애플리케이션: [$app] | 버전: [$ver] 배포에 실패했습니다." >> deployment.log
    echo "❌ [$user_id]의 Helm 배포 중 오류가 발생했습니다."
  fi
fi
