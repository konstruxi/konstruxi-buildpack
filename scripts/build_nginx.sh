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


echo "BUILD NGINX";

temp_dir=$(mktemp -d /tmp/nginx.XXXXXXXXXX)

echo "Serving files from /tmp on $PORT"
cd /tmp
python -m SimpleHTTPServer $PORT &

cd $temp_dir
echo "Temp dir: $temp_dir"


# Main dependencies
git clone https://github.com/nginx/nginx --depth=1;
git clone https://github.com/konstruxi/form-input-nginx-module --depth=1;
git clone https://github.com/konstruxi/ngx_postgres --depth=1;
git clone https://github.com/konstruxi/mustache-nginx-module --depth=1;
git clone https://github.com/openresty/nginx-eval-module.git --depth=1;

# Optional dependencies
git clone https://github.com/openresty/echo-nginx-module.git --depth=1;
git clone https://github.com/simpl/ngx_devel_kit.git --depth=1;
git clone https://github.com/openresty/set-misc-nginx-module.git --depth=1;
git clone https://github.com/vkholodkov/nginx-upload-module.git --depth=1;
git clone https://github.com/masterzen/nginx-upload-progress-module.git --depth=1;

# Compile nginx (change path to your app)
env APP_PATH=./skema ./skema/compile-nginx.sh


while true
do
	sleep 1
	echo "."
done
