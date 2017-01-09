#!/bin/bash
# Build NGINX and modules on Heroku.
# This program is designed to run in a web dyno provided by Heroku.
# We would like to build an NGINX binary for the builpack on the
# exact machine in which the binary will run.
# Our motivation for running in a web dyno is that we need a way to
# download the binary once it is built so we can vendor it in the buildpack.
#
# Once the dyno has is 'up' you can open your browser and navigate
# this dyno's directory structure to download the nginx binary.


# sudo apt-get install curl
# sudo apt-get install libssl-dev
# sudo apt-get install libpq-dev

echo "BUILD NGINX";

temp_dir=$(mktemp -d /tmp/nginx.XXXXXXXXXX)

echo "Serving files from /tmp on $PORT"
cd /tmp
python -m SimpleHTTPServer $PORT &

cd $temp_dir
echo "Temp dir: $temp_dir"

PCRE_VERSION=${PCRE_VERSION-8.21}
NGINX_VERSION=${NGINX_VERSION-1.11.2}

pcre_tarball_url=http://ncu.dl.sourceforge.net/project/pcre/pcre/${PCRE_VERSION}/pcre-${PCRE_VERSION}.tar.bz2
nginx_tarball_url=http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz

echo "Downloading $nginx_tarball_url"
mkdir nginx;
curl -L $nginx_tarball_url | tar xzv -C ./nginx --strip-components=1

echo "Downloading $pcre_tarball_url"
(curl -L $pcre_tarball_url | tar xvj)

# Main dependencies
git clone https://github.com/konstruxi/skema --depth=1;
git clone https://github.com/konstruxi/form-input-nginx-module --depth=1;
git clone https://github.com/konstruxi/ngx_postgres --depth=1;
git clone https://github.com/konstruxi/mustache-nginx-module --depth=1;
git clone https://github.com/konstruxi/nginx-eval-module.git --depth=1;

# Optional dependencies
git clone https://github.com/FRiCKLE/ngx_coolkit.git --depth=1;
git clone https://github.com/openresty/echo-nginx-module.git --depth=1;
git clone https://github.com/simpl/ngx_devel_kit.git --depth=1;
git clone https://github.com/openresty/set-misc-nginx-module.git --depth=1;
git clone https://github.com/vkholodkov/nginx-upload-module.git --depth=1;
git clone https://github.com/masterzen/nginx-upload-progress-module.git --depth=1;

# Compile nginx (change path to your app)

if [ -z "$APP_PATH" ]; then APP_PATH="../skema"; fi

cd nginx;

env CFLAGS="-Wno-error" ./configure \
  --with-cc-opt="-O1 -std=c99" \
  --with-ld-opt="-lm" \
  --prefix=$APP_PATH/conf \
  --with-http_ssl_module \
  --with-pcre=../pcre-${PCRE_VERSION} \
  --with-ipv6 \
  --sbin-path=../bin/nginx \
  --conf-path=nginx.conf \
  --pid-path=../temp/run/nginx.pid \
  --lock-path=../temp/run/nginx.lock \
  --http-client-body-temp-path=../temp/client_body_temp \
  --http-proxy-temp-path=../temp/proxy_temp \
  --http-fastcgi-temp-path=../temp/fastcgi_temp \
  --http-uwsgi-temp-path=../temp/uwsgi_temp \
  --http-scgi-temp-path=../temp/scgi_temp \
  --http-log-path=../logs/access.log \
  --error-log-path=../logs/error.log \
  --with-debug \
  --add-module=../ngx_devel_kit \
  --add-module=../set-misc-nginx-module \
  --add-module=../form-input-nginx-module \
  --add-module=../ngx_postgres \
  --add-module=../mustache-nginx-module \
  --add-module=../echo-nginx-module \
  --add-module=../nginx-eval-module \
  --add-module=../ngx_coolkit;
make install;
rm -rf $APP_PATH/conf/fastcgi.conf;
rm -rf $APP_PATH/conf/fastcgi.conf.default;
rm -rf $APP_PATH/conf/fastcgi_params;
rm -rf $APP_PATH/conf/fastcgi_params.default;
rm -rf $APP_PATH/conf/koi-utf;
rm -rf $APP_PATH/conf/koi-win;
rm -rf $APP_PATH/conf/win-utf;
rm -rf $APP_PATH/conf/scgi_params;
rm -rf $APP_PATH/conf/scgi_params.default;
rm -rf $APP_PATH/conf/uwsgi_params;
rm -rf $APP_PATH/conf/uwsgi_params.default;
rm -rf $APP_PATH/conf/html;

while true
do
	sleep 1
	echo "."
done
