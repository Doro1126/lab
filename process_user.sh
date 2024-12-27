#!/bin/bash
# process_user.sh

# `fetch_users.sh`에서 전달된 변수를 확인
echo "🔄 사용자 정보 확인 중..."
echo "$user_data"

# 사용자별 처리
for row in $user_data; do
  user_id=$(echo "$row" | awk '{print $1}')
  app=$(echo "$row" | awk '{print $2}')
  ver=$(echo "$row" | awk '{print $3}')
  cpu=$(echo "$row" | awk '{print $4}')
  ram=$(echo "$row" | awk '{print $5}')
  
  echo "🚀 사용자 [$user_id]: 애플리케이션 [$app] (버전: $ver) | CPU: ${cpu} Core | RAM: ${ram}MB 처리 완료."
done
