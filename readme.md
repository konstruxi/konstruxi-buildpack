Compile konstruxi nginx stack and its dependencies:

mkdir konstruxi;

git clone https://github.com/konstruxi/konstruxi-buildpack --depth=1;

APP_PATH='myapp' ./konstruxi-buildpack/scripts/build_nginx.sh;

cd myapp;

PORT=80 DATABASE_URL=psql://user:password@localhost/database ./bin/start-nginx-app;