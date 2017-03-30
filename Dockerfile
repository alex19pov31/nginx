FROM  debian:8
MAINTAINER Nesterov Alexander <alex19pov31@gmail.com>

RUN NPS_VERSION=1.12.34.2 && \
ZLIB_VERSION=1.2.11 && \
NGINX_VERSION=1.10.3 && \
OPENSSL_VERSION=1.1.0e && \
groupadd nginx && useradd -g nginx nginx && \
mkdir -p /var/log/nginx /usr/lib/nginx/modules /var/cache/nginx /etc/nginx/extra/dmodules && \
touch /etc/nginx/extra/dmodules/config && \
chown nginx:nginx /var/log/nginx /usr/lib/nginx /var/cache/nginx /etc/nginx && \
apt-get update && apt-get install wget build-essential zlib1g-dev libpcre3 libpcre3-dev unzip libgd-dev libgeoip-dev libxml2-dev libxslt-dev libperl-dev -y && \
cd /usr/local/src && \
wget https://github.com/pagespeed/ngx_pagespeed/archive/v${NPS_VERSION}-beta.zip && \
unzip v${NPS_VERSION}-beta.zip && \
cd ngx_pagespeed-${NPS_VERSION}-beta/ && \
psol_url=https://dl.google.com/dl/page-speed/psol/${NPS_VERSION}.tar.gz [ -e scripts/format_binary_url.sh ] && psol_url=$(scripts/format_binary_url.sh PSOL_BINARY_URL) && \
wget ${psol_url} && \
tar -xzvf $(basename ${psol_url}) && \
cd /usr/local/src && \
wget http://zlib.net/zlib-${ZLIB_VERSION}.tar.gz && \
wget https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz && \
tar -xzvpf zlib-${ZLIB_VERSION}.tar.gz && \
tar -xzvpf openssl-${OPENSSL_VERSION}.tar.gz && \
cd /usr/local/src && \
wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && \
tar -xvzf nginx-${NGINX_VERSION}.tar.gz && \
cd nginx-${NGINX_VERSION}/ && \
./configure --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --modules-path=/usr/lib/nginx/modules --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --http-client-body-temp-path=/var/cache/nginx/client_temp --http-proxy-temp-path=/var/cache/nginx/proxy_temp --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp --http-scgi-temp-path=/var/cache/nginx/scgi_temp --user=nginx --group=nginx --add-module=/usr/local/src/ngx_pagespeed-${NPS_VERSION}-beta ${PS_NGX_EXTRA_FLAGS} --with-pcre --with-zlib=/usr/local/src/zlib-${ZLIB_VERSION} --with-openssl=/usr/local/src/openssl-${OPENSSL_VERSION} --with-http_ssl_module --with-http_realip_module --with-http_addition_module --with-http_sub_module --with-http_dav_module --with-http_flv_module --with-http_mp4_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_random_index_module --with-http_secure_link_module --with-http_stub_status_module --with-http_auth_request_module --with-http_xslt_module=dynamic --with-http_image_filter_module=dynamic --with-http_geoip_module=dynamic --with-http_perl_module=dynamic --add-dynamic-module=/etc/nginx/extra/dmodules --with-threads --with-stream --with-stream_ssl_module --with-http_slice_module --with-mail --with-mail_ssl_module --with-file-aio --with-ipv6 --with-http_v2_module --with-cc-opt='-g -O2 -fstack-protector-strong -Wformat -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2' --with-ld-opt='-Wl,-z,relro -Wl,--as-needed' && \
make && make install && \
rm -rf /var/lib/apt/lists/* && \
ln -sf /dev/stdout /var/log/nginx/access.log && \
ln -sf /dev/stderr /var/log/nginx/error.log

COPY conf/ /

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]