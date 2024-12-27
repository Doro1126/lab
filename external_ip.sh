#!/bin/bash
# external_ip.sh

# External IP 가져오기
external_ip=$(kubectl get svc -n "web-$user_id" -o jsonpath='{range .items[*]}{.status.loadBalancer.ingress[0].ip}{"\n"}{end}' | grep -Eo '([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)' | head -n1)

# DB 도메인 설정
db_dns="$user_id-db-svc.web-$user_id.svc.cluster.local"

# External IP 확인
if [[ -z "$external_ip" ]]; then
  echo "⚠️ [$user_id]의 External IP를 아직 할당받지 못했습니다."
else
  echo "✅ [$user_id]에 할당된 접속 주소: http://$external_ip"
  echo "$(date): 🟢 [$user_id]의 접속 주소: http://$external_ip" >> deployment.log

  echo "📡 [$user_id]의 External IP를 데이터베이스에 저장합니다..."
  mysql -u root -B -P 3306 -e "USE webapp_db; UPDATE users SET pub_ip='$external_ip' WHERE user_id='$user_id';"
  if [[ $? -eq 0 ]]; then
    echo "✅ [$user_id]의 External IP가 데이터베이스에 성공적으로 저장되었습니다."
  else
    echo "❌ [$user_id]의 External IP 저장 중 오류가 발생했습니다."
  fi
fi

# DB 도메인 저장
if [[ -n "$db_dns" ]]; then
  echo "📡 [$user_id]의 DB 도메인 주소를 데이터베이스에 저장합니다..."
  mysql -u root -B -P 3306 -e "USE webapp_db; UPDATE users SET db_dns='$db_dns' WHERE user_id='$user_id';"
  if [[ $? -eq 0 ]]; then
    echo "✅ [$user_id]의 DB 도메인 주소가 데이터베이스에 성공적으로 저장되었습니다."
  else
    echo "❌ [$user_id]의 DB 도메인 주소 저장 중 오류가 발생했습니다."
  fi
else
  echo "⚠️ [$user_id]의 DB 도메인 주소가 설정되지 않았습니다."
fi

