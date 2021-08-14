# resty-jwt
Simple project with downlaoder and installation of files required for jwt and simple stitched lua file for performing the auth




How to require JWT
```conf

lua_package_path "/usr/local/openresty/nginx/jwt-lua/?.lua;;";
server {
        listen 80;
        listen 443 ssl;
        server_name _;
        ssl_certificate /usr/local/openresty/nginx/conf/tmp_ssl/certs/nginx-selfsigned.crt;
        ssl_certificate_key /usr/local/openresty/nginx/conf/tmp_ssl/private/nginx-selfsigned.key;

        set $uid '';
        location / {
            access_by_lua '
            local jwt = require("resty.nginx-jwt")
            jwt.auth()
        ';
            default_type application/json;
            proxy_set_header uid $uid;
            proxy_pass http://localhost:80;
        }
        location /gate {
            proxy_cache off;
            root   /usr/local/openresty/nginx/html/index.html;
        }

}

```















