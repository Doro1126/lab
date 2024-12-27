#!/bin/bash

# 🛡️ 안전장치: 사용자 확인
read -p "⚠️ 이 스크립트는 Helm 릴리스, 네임스페이스, 로컬 디렉토리 및 DB users 테이블의 모든 데이터를 삭제합니다. 계속 진행할까요? (y/N): " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
  echo "❌ 작업이 취소되었습니다."
  exit 1
fi

# 🔍 MySQL에서 user_id 목록 가져오기
user_ids=$(mysql -B -e 'USE webapp_db; SELECT user_id FROM users;' | tail -n +2)

# 디버깅용
echo "🔍 가져온 사용자 목록:"
echo "$user_ids"

# IFS 설정: 줄바꿈 기준으로 처리
IFS=$'\n'
for user_id in $user_ids; do
  echo "🚀 [$user_id] 사용자 리소스 정리 중..."

  # 1️⃣ Helm 릴리스 삭제
  echo "📦 [$user_id]의 Helm 릴리스를 삭제합니다..."
  if helm uninstall "$user_id-helm" --namespace "web-$user_id" >/dev/null 2>&1; then
    echo "✅ [$user_id]의 Helm 릴리스가 성공적으로 삭제되었습니다."
  else
    echo "⚠️ [$user_id]의 Helm 릴리스가 존재하지 않거나 삭제에 실패했습니다."
  fi

  # 2️⃣ Kubernetes 네임스페이스 삭제
  echo "🗑️ [$user_id] 네임스페이스를 삭제합니다..."
  if kubectl delete namespace "web-$user_id" --ignore-not-found >/dev/null 2>&1; then
    echo "✅ [$user_id]의 네임스페이스가 성공적으로 삭제되었습니다."
  else
    echo "⚠️ [$user_id]의 네임스페이스가 존재하지 않거나 삭제에 실패했습니다."
  fi

  # 3️⃣ 로컬 디렉토리 삭제
  echo "📂 [$user_id] 로컬 디렉토리를 삭제합니다..."
  if [[ -d "$user_id" ]]; then
    rm -rf "$user_id"
    echo "✅ [$user_id]의 로컬 디렉토리가 성공적으로 삭제되었습니다."
  else
    echo "⚠️ [$user_id]의 로컬 디렉토리가 존재하지 않습니다."
  fi

  echo "✅ [$user_id]의 모든 리소스가 정리되었습니다."
  echo "--------------------------------------------"
done

unset IFS

# 4️⃣ 데이터베이스 users 테이블 데이터 삭제
echo "🛡️ users 테이블의 모든 데이터를 삭제합니다."
read -p "⚠️ 정말로 데이터베이스 users 테이블의 모든 데이터를 삭제할까요? (y/N): " confirm_db
if [[ "$confirm_db" != "y" && "$confirm_db" != "Y" ]]; then
  echo "❌ users 테이블 데이터 삭제가 취소되었습니다."
else
  mysql -B -e "USE webapp_db; DELETE FROM users;"
  if [[ $? -eq 0 ]]; then
    echo "✅ users 테이블의 모든 데이터가 성공적으로 삭제되었습니다."
  else
    echo "❌ users 테이블 데이터 삭제 중 오류가 발생했습니다."
  fi
fi

# 🎯 최종 메시지
echo "✅ 모든 사용자 리소스 및 데이터베이스 데이터가 성공적으로 정리되었습니다."

