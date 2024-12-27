#!/bin/bash
# helm_setup.sh

# 디렉터리 존재 여부 확인
if [[ -d "$user_id" ]]; then
  echo "✅ [$user_id]의 Helm 차트가 이미 존재합니다. 스킵합니다."
else
  helm create "$user_id"
  echo "📦 [$user_id]의 Helm 차트를 새로 생성했습니다."
fi

# 불필요한 템플릿 파일 삭제
echo "🗑️ [$user_id]의 불필요한 템플릿 파일을 삭제합니다."
rm -f "$user_id/templates/hpa.yaml"
rm -f "$user_id/templates/ingress.yaml"
rm -f "$user_id/templates/NOTES.txt"
rm -f "$user_id/templates/serviceaccount.yaml"
echo "✅ [$user_id]의 불필요한 파일을 정리했습니다."

# deployment.yaml 및 service.yaml 복사
echo "📑 [$user_id]의 템플릿 디렉터리에 deployment.yaml 및 service.yaml을 복사합니다."
cp deployment.yaml "$user_id/templates/deployment.yaml"
cp service.yaml "$user_id/templates/service.yaml"
echo "✅ [$user_id]에 사용자 정의 템플릿 파일을 복사했습니다."

# values.yaml 템플릿 파일 설정
echo "⚙️ [$user_id]의 values.yaml 파일을 설정합니다."
cp values.yaml "$user_id/values.yaml"
sed -i "s|APP|$app|g" "$user_id/values.yaml"
sed -i "s|VERSION|$ver|g" "$user_id/values.yaml"
sed -i "s|USER_ID|$user_id|g" "$user_id/values.yaml"
sed -i "s|CPU|$cpu|g" "$user_id/values.yaml"
sed -i "s|RAM|$ram|g" "$user_id/values.yaml"
echo "✅ [$user_id]의 values.yaml 파일이 성공적으로 업데이트되었습니다."
