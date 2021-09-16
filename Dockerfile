FROM openresty/openresty:buster
EXPOSE 80

COPY ./nginx.conf.template /usr/local/openresty/nginx/conf/nginx.conf.template
COPY ./lib/* /usr/local/openresty/nginx/jwt-lua/resty/
COPY ./project/* /usr/local/openresty/nginx/jwt-lua/resty/
COPY ./entrypoint.sh /usr/local/openresty/nginx/entrypoint.sh
RUN mkdir -p /usr/local/openresty/nginx/html/gate

RUN \
    apt update && \
    apt upgrade -y && \
    apt install -y --no-install-recommends \
    jq \
    openssl \
    curl \
    iproute2

WORKDIR /usr/local/openresty/nginx/


RUN ["chmod", "+x", "./entrypoint.sh"]
CMD ["/usr/bin/openresty", "-g", "daemon off;"]
ENTRYPOINT ["./entrypoint.sh"]