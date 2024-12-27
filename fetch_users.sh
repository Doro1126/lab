#!/bin/bash
# fetch_users.sh

# 🔍 MySQL에서 사용자 정보 가져오기
user_data=$(mysql -e 'USE webapp_db; SELECT user_id, app, ver, cpu, ram FROM users;' | tail -n +2)

# 변수 출력 확인 (디버깅용)
echo "🔍 데이터베이스에서 사용자 정보를 가져왔습니다:"
echo "$user_data"

# IFS 설정: 줄바꿈 기준으로 처리
export IFS=$'\n'
export user_data
