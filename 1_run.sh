#!/bin/sh
# ---------------------------------------------------------------------------------------
#   Kubernates / 2022_05_17 / ANa
# ---------------------------------------------------------------------------------------

echo -e "\n"
echo ------------------------------------------------------ Create temp folders kubernates_root
mkdir ./kubernates_root
chmod 777 ./kubernates_root
cd kubernates_root



echo -e "\n"
echo ------------------------------------------------------ Create index.html
cat << EOF > ./index.html
<!-- ----------------------------- index.html START -------------------- -->
<!DOCTYPE html>
<html>
<body>
<h2>Page created by Andrey</h2>
</body>
</html>
<!-- ----------------------------- index.html END -------------------- -->
EOF
cat ./index.html



echo -e "\n"
echo ------------------------------------------------------ Create nginx.conf
cat << EOF > ./nginx.conf
# ----------------------------- nginx.conf START --------------------
user nginx;
worker_processes  1;
events {
  worker_connections  10240;
}
http {
  server {
      listen       80;
      server_name  localhost;
      location / {
        auth_basic           "Module_D3 Private Zone";
        auth_basic_user_file /etc/nginx/.htpasswd; 
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }
  }
}
# ----------------------------- nginx.conf END  --------------------
EOF
cat ./nginx.conf



echo -e "\n"
echo ------------------------------------------------------ Create Dockerfile
cat << EOF > ./Dockerfile
# ----------------------------- Dockerfile START --------------------
FROM nginx:1.21.1-alpine

RUN apk --update --no-cache --virtual build-dependencies add apache2-utils

COPY ./nginx.conf /etc/nginx/nginx.conf
COPY ./index.html /usr/share/nginx/html/index.html
COPY ./and5_generate_nginx_credentials.sh /etc/nginx/and5_generate_nginx_credentials.sh

EXPOSE 80

# ----------------------------- Dockerfile END  --------------------
EOF
cat ./Dockerfile



echo -e "\n"
echo ------------------------------------------------------ Create and5_generate_nginx_credentials.sh
cat << EOF > ./and5_generate_nginx_credentials.sh
#!/bin/sh
# ----------------------------- and5_generate_nginx_credentials.sh START --------------------
# ---------------------------------------------------------------------------------------
#   Kubernates / 2022_05_17 / ANa
# ---------------------------------------------------------------------------------------

if [ -z "\$NGINX_USERNAME" ]
then
      export NGINX_USERNAME=andrey
fi

if [ -z "\$NGINX_PASSWORD" ]
then
      export NGINX_PASSWORD=andrey
fi

htpasswd -b -c /etc/nginx/.htpasswd \$NGINX_USERNAME \$NGINX_PASSWORD

# ----------------------------- and5_generate_nginx_credentials.sh END  --------------------
EOF
cat ./and5_generate_nginx_credentials.sh


echo -e "\n"
echo ------------------------------------------------------ Publishing Image into Docker HUB
docker rm `docker ps -q -l`
docker image rm `docker image ls -q` -f
docker build -t andreyk8s . 
docker tag `docker images -q andreyk8s` silverstandart/andreyk8s:latest
docker push silverstandart/andreyk8s:latest


