#!/bin/bash
# external_ip.sh

# External IP 가져오기 (Retry 로직 포함)
MAX_RETRIES=5    # 최대 5번 재시도
RETRY_INTERVAL=10  # 각 재시도 사이 10초 대기

attempt=1
while [[ $attempt -le $MAX_RETRIES ]]; do
  echo "🔄 [$user_id] External IP 가져오기 (시도: $attempt/$MAX_RETRIES)..."
  external_ip=$(kubectl get svc -n "web-$user_id" -o jsonpath='{range .items[?(@.spec.type=="LoadBalancer")]}{.status.loadBalancer.ingress[*].hostname}{end}')
  external_ip=$(echo "$external_ip" | xargs)  # 공백 제거

  if [[ -n "$external_ip" ]]; then
    echo "✅ External IP: $external_ip"
    break
  else
    echo "⚠️ External IP가 아직 할당되지 않았습니다. $RETRY_INTERVAL초 후 재시도..."
    sleep $RETRY_INTERVAL
    ((attempt++))
  fi
done

# 최대 재시도 이후 실패 처리
if [[ -z "$external_ip" ]]; then
  echo "❌ External IP를 가져오지 못했습니다. 스크립트를 종료합니다."
  exit 1
fi

# DB 도메인 설정
db_dns="$user_id-db-svc.web-$user_id.svc.cluster.local"

# External IP 확인
if [[ -z "$external_ip" ]]; then
  echo "⚠️ [$user_id]의 External IP를 아직 할당받지 못했습니다."
else
  echo "✅ [$user_id]에 할당된 접속 주소: http://$external_ip"
  echo "$(date): 🟢 [$user_id]의 접속 주소: http://$external_ip" >> deployment.log

  echo "📡 [$user_id]의 External IP를 데이터베이스에 저장합니다..."
  mysql -e "USE webapp_db; UPDATE users SET pub_ip='$external_ip' WHERE user_id='$user_id';"
  if [[ $? -eq 0 ]]; then
    echo "✅ [$user_id]의 External IP가 데이터베이스에 성공적으로 저장되었습니다."
  else
    echo "❌ [$user_id]의 External IP 저장 중 오류가 발생했습니다."
  fi
fi

# DB 도메인 저장
if [[ -n "$db_dns" ]]; then
  echo "📡 [$user_id]의 DB 도메인 주소를 데이터베이스에 저장합니다..."
  mysql -e "USE webapp_db; UPDATE users SET db_dns='$db_dns' WHERE user_id='$user_id';"
  if [[ $? -eq 0 ]]; then
    echo "✅ [$user_id]의 DB 도메인 주소가 데이터베이스에 성공적으로 저장되었습니다."
  else
    echo "❌ [$user_id]의 DB 도메인 주소 저장 중 오류가 발생했습니다."
  fi
else
  echo "⚠️ [$user_id]의 DB 도메인 주소가 설정되지 않았습니다."
fi


