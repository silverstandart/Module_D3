#!/bin/sh
# ---------------------------------------------------------------------------------------
#   Kubernates / 2022_05_17 / ANa
# ---------------------------------------------------------------------------------------

alias k=kubectl
alias m=minikube


echo -e "\n"
echo ------------------------------------------------------ Create temp folders kubernates_root
mkdir ./kubernates_root
chmod 777 ./kubernates_root
cd kubernates_root



echo -e "\n"
echo ------------------------------------------------------ Create and5-secret.yml
cat << EOF > ./and5-secret.yml
# ----------------------------- and5-secret.yml START --------------------
apiVersion: v1
kind: Secret
metadata:
  name: auth-basic
type: kubernetes.io/basic-auth
stringData:
  username: user1
  password: password1
# ----------------------------- and5-secret.yml END  --------------------
EOF
cat ./and5-secret.yml



echo -e "\n"
echo ------------------------------------------------------ Create and5-dl.yml
cat << EOF > ./and5-dl.yml
# ----------------------------- and5-dl.yml START --------------------
apiVersion : apps/v1
kind: Deployment
metadata:
  name: nginx-sf
  labels:
    tier: 2tiers
    owner: andrey
spec:
  replicas: 3
  selector:
    matchLabels:
      tier: 2tiers
  template: 
    metadata:
      labels:
        tier: 2tiers
    spec: 
      containers:
        - name: and5-container-replica
          image: silverstandart/andreyk8s:latest
          ports:
            - containerPort: 80
          env:
            - name: NGINX_USERNAME
              valueFrom:
                secretKeyRef:
                  name: auth-basic
                  key: username
            - name: NGINX_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: auth-basic
                  key: password
          command: ["/bin/sh"]
          args: ["-c", "chmod 777 /etc/nginx/and5_generate_nginx_credentials.sh; /etc/nginx/and5_generate_nginx_credentials.sh; /usr/sbin/nginx -g 'daemon off;'"]


---
apiVersion: v1
kind: Service
metadata:
  name: sf-webserver
spec:
  type: NodePort
  selector:
    tier: 2tiers
  ports:
  - name: http
    protocol: TCP
    port: 80
    targetPort: 80
# ----------------------------- and5-dl.yml END  --------------------
EOF
cat ./and5-dl.yml



echo -e "\n"
echo ------------------------------------------------------ Create Kubernates Cluster
m -p and5-main start --cpus=2 --memory=8gb --namespace and5-ns
k create namespace and5-ns

k delete -f and5-secret.yml
k apply  -f and5-secret.yml
k delete -f and5-dl.yml
k apply  -f and5-dl.yml

sleep 10

k get pods --selector=tier=2-4tiers -o jsonpath='{.items[*].status.podIP}'
echo -e "\n"

echo -e "\n"
echo ------------------------------------------------------ Pods Info
k get pods --show-labels

echo -e "\n"
echo ------------------------------------------------------ Services Info
k get services --show-labels

echo -e "\n"
k describe services sf-webserver

echo -e "\n"
k get pods -o wide -o yaml | grep podIP

echo -e "\n"
kubectl get nodes -o jsonpath='{.items[*].status.addresses[?(@.type=="ExternalIP")].address}'

echo -e "\n"
echo ------------------------------------------------------
echo -- NOTE to see tunnel use command in new console -----
echo m service list -p and5-main
echo ------------------------------------------------------

echo -e "\n"
m tunnel -p and5-main


