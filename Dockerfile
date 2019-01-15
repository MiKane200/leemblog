FROM monachus/hugo

COPY . /app
WORKDIR /app
RUN hugo

FROM nginx
COPY auto_devops/default.conf /etc/nginx/conf.d/default.conf
COPY auto_devops/auth_basic_user_file /
COPY --from=0 /app/public /usr/share/nginx/html