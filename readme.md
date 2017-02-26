## Konstruxi reciepe

A reciepe to create a new konstruxi app and its dependencies from sources. It also contains heroku reciepe.


## Requirements:

LIBSSL: `sudo apt-get install libssl-dev`
LIBPQ:  `sudo apt-get install libpq-dev`

You will need *superuser* for postgre to activate necessary extensions (currently only ossn-uuid)



## Installation
    mkdir konstruxi;

    # Clone reciepe
    git clone https://github.com/konstruxi/konstruxi-buildpack --depth=1;

    # Clone & Compile nginx
    APP_PATH='myapp' ./konstruxi-buildpack/scripts/build_nginx.sh;


    cd myapp;
    
    cd model;

    # Run PSQL installation script
    ./rebuild.sh;
    cd ..;

    # Compile config with your PG connection & HTTP port settings
    PORT=80 DATABASE_URL=psql://user:password@localhost/database erb conf/heroku/nginx.conf.erb > conf/heroku.conf;

    # Run nginx with the config
    bin/nginx -p ./conf -c ./heroku.conf;