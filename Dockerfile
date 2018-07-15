FROM registry.saas.hand-china.com/hep/hugo:latest

COPY . /app
WORKDIR /app
#RUN hugo

FROM registry.saas.hand-china.com/tools/nginx:latest
COPY auto_devops/default.conf /etc/nginx/conf.d/default.conf
COPY auto_devops/auth_basic_user_file /
COPY --from=0 /app/public /usr/share/nginx/html