#!/bin/bash

# Kubernetes YAML 파일 생성 스크립트

# deployment.yaml 생성
cat <<EOF > deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: "{{ .Values.username }}-{{ .Values.containerName }}"
  labels:
    app: "{{ .Chart.Name }}"
spec:
  replicas: 1
  selector:
    matchLabels:
      app: "{{ .Chart.Name }}"
  template:
    metadata:
      labels:
        app: "{{ .Chart.Name }}"
    spec:
      containers:
        - name: "{{ .Values.containerName }}"
          image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
          env:
            - name: WORDPRESS_DB_HOST
              value: "{{ .Values.username }}-db-svc.web-{{ .Values.username }}.svc.cluster.local"
            - name: WORDPRESS_DB_NAME
              value: "{{ .Values.username }}"
            - name: WORDPRESS_DB_USER
              value: "{{ .Values.username }}"
            - name: WORDPRESS_DB_PASSWORD
              value: "{{ .Values.username }}"
          ports:
            - containerPort: 80
          resources:
            limits:
              memory: "{{ .Values.resources.ram }}"
              cpu: "{{ .Values.resources.cpu }}"

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: "{{ .Values.username }}-{{ .Values.db.containerName }}"
  labels:
    app: "{{ .Chart.Name }}-db"
spec:
  replicas: 1
  selector:
    matchLabels:
      app: "{{ .Chart.Name }}-db"
  template:
    metadata:
      labels:
        app: "{{ .Chart.Name }}-db"
    spec:
      containers:
        - name: "{{ .Values.db.containerName }}"
          image: "{{ .Values.db.image }}"
          ports:
            - containerPort: {{ .Values.db.service.port }}
          env:
            - name: MYSQL_ROOT_PASSWORD
              value: "{{ .Values.username }}"
            - name: MYSQL_DATABASE
              value: "{{ .Values.username }}"
            - name: MYSQL_USER
              value: "{{ .Values.username }}"
            - name: MYSQL_PASSWORD
              value: "{{ .Values.username }}"
            - name: MYSQL_AUTHENTICATION_PLUGIN
              value: mysql_native_password
          command: ["sh", "-c"]
          args:
            - |
              echo "Initializing database..."
              docker-entrypoint.sh mysqld &
              sleep 10
              echo "Creating MySQL user and database..."
              mysql -u root -p\${MYSQL_ROOT_PASSWORD} -e "CREATE USER IF NOT EXISTS '\${MYSQL_USER}'@'%' IDENTIFIED BY '\${MYSQL_PASSWORD}';"
              mysql -u root -p\${MYSQL_ROOT_PASSWORD} -e "GRANT ALL PRIVILEGES ON \${MYSQL_DATABASE}.* TO '\${MYSQL_USER}'@'%';"
              mysql -u root -p\${MYSQL_ROOT_PASSWORD} -e "FLUSH PRIVILEGES;"
              wait
          volumeMounts:
            - name: mysql-storage
              mountPath: /var/lib/mysql
      volumes:
        - name: mysql-storage
          emptyDir: {}
EOF

# service.yaml 생성
cat <<EOF > service.yaml
apiVersion: v1
kind: Service
metadata:
  name: {{ .Values.username }}-svc
  labels:
    app: {{ .Chart.Name }}
spec:
  type: {{ .Values.service.type }}
  selector:
    app: {{ .Chart.Name }}
  ports:
  - protocol: TCP
    port: {{ .Values.service.port }}
    targetPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: "{{ .Values.username }}-db-svc"
  labels:
    app: "{{ .Chart.Name }}-db"
spec:
  type: {{ .Values.db.service.type }}
  selector:
    app: "{{ .Chart.Name }}-db"
  ports:
    - protocol: TCP
      port: {{ .Values.db.service.port }}
      targetPort: {{ .Values.db.service.port }}
EOF

# values.yaml 생성
cat <<EOF > values.yaml
# 사용자 이름
username: USER_ID

# 컨테이너 이름 (APP 값 사용)
containerName: APP

image:
  repository: doro0704/APP
  pullPolicy: IfNotPresent
  tag: VERSION

service:
  type: LoadBalancer
  port: 80

# DB 설정
db:
  enabled: true
  image: mysql:5.7
  containerName: db
  service:
    type: ClusterIP
    port: 3306

resources:
  cpu: CPU
  ram: RAMMi
EOF

echo "✅ Kubernetes YAML 파일이 성공적으로 생성되었습니다!"
echo "📄 생성된 파일:"
echo "- deployment.yaml"
echo "- service.yaml"
echo "- values.yaml"

