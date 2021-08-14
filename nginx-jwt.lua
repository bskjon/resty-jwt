local jwt = require "resty.jwt"
local cjson = require "cjson"
--your secret
local secret = (os.getenv("secret") and os.getenv("secret") ~= '') and os.getenv("secret") or "eO5zESo8livHiDWxwn+J5U7h5cAZPgWZr4JymG94zB0="
-- local secret = "5pil6aOO5YaN576O5Lmf5q+U5LiN5LiK5bCP6ZuF55qE56yR"

local M = {}

function M.auth(claim_specs)
    ---
    local h = ngx.req.get_headers()
    local request_headers_all = ""
    for k, v in pairs(h) do
        local rowtext = ""
        rowtext = string.format("[%s %s]\n", k, v)
        request_headers_all = request_headers_all .. rowtext

    end
    ngx.log(ngx.INFO, "DATA:" .. request_headers_all)

    ---
    if secret ~= nil then
        ngx.log(ngx.INFO, "Using secret to validate: " .. secret)
    end

    -- require Authorization request header
    local auth_header = ngx.var.http_Authorization
    local cookie_token = ngx.var.cookie_token

    -- aborting if both is empty
    if auth_header == nil and cookie_token == nil then
        ngx.log(ngx.WARN, "No Authorization header")
        ngx.exit(ngx.HTTP_UNAUTHORIZED)
    end

    -- require Bearer token
    local _, _, token = string.find(auth_header, "Bearer%s+(.+)")

    -- writing auth header if used
    if token ~= nil and auth_header ~= nil then
        ngx.log(ngx.INFO, "Authorization: " .. auth_header)
    end

    -- if token is null, check cookie
    if token == nil and cookie_token ~= nil then
        _, _, token = string.find(auth_header, "Bearer%s+(.+)")
        if token ~= nil and cookie_token ~= nil then
            ngx.log(ngx.INFO, "Cookie: " .. cookie_token)
        end
    end


    if token == nil then
        ngx.log(ngx.WARN, "Missing token")
        ngx.exit(ngx.HTTP_UNAUTHORIZED)
    end

    ngx.log(ngx.INFO, "Token: " .. token)

    local jwt_obj = jwt:verify(secret, token)
    if jwt_obj.verified == false then
        ngx.log(ngx.WARN, "Invalid token: ".. jwt_obj.reason)
        ngx.exit(ngx.HTTP_UNAUTHORIZED)
    end

--    ngx.log(ngx.INFO, "JWT: " .. cjson.encode(jwt_obj))


    -- setting header -- if used later and cookie is passed
    ngx.req.set_header("Authorization", "Bearer " .. token)

    -- write the uid variable
    ngx.var.uid = jwt_obj.payload.sub
end

return M
