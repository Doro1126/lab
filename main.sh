#!/bin/bash
# main.sh

# 변수 가져오기
source ./fetch_users.sh

# 사용자 처리
source ./process_user.sh

# 추가 단계
source ./helm_setup.sh
source ./deployment_check.sh
source ./external_ip.sh
