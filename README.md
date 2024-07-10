
# Table of Contents

1.  [Introduction](#org5bbca58)
2.  [Building the image](#org05a38b8)
3.  [Preparing the Keys.](#orgd5bb0f3)
    1.  [MDH account secret key](#orge8fd242)
    2.  [Creating the superset DB key](#org6e123e1)
4.  [Environment Variables](#orgf0f7648)
5.  [Creating a volume](#orgb67a79f)
6.  [Running the Container](#org2eebd50)
    1.  [Running it in foreground [interactive / with output]](#org275403d)
        1.  [Create the container](#orgbac21dc)
        2.  [Start the container](#orgbe36282)
        3.  [Cleaning up](#orgdb41442)
    2.  [Running it in background [non-interactive]](#org27cc771)



<a id="org5bbca58"></a>

# Introduction

This documents details how to build the customer docker image.


<a id="org05a38b8"></a>

# Building the image

Use the following commands to build the docker image.

    docker build -t nextgensh/superset-sf .

If you want to build / re-build the image without using any cache layers then pass the
`--no-cache` option to `docker build`.


<a id="orgd5bb0f3"></a>

# Preparing the Keys.

Keys are a mysterious gateway to knowledge. You will need a few of them!


<a id="orge8fd242"></a>

## MDH account secret key

The MDH account secret key needs to be first converted into base64 to remove newlines. This is needed as docker / Cyverse does not support multiline environment variables.

> Pass this to the environment variable `MDH_SECRET`

    # $path variable holds the file path to where your key is stored.
    cat $path | base64


<a id="org6e123e1"></a>

## Creating the superset DB key

This key will be used to encrypt local meta-data db and keep everything safe.

> Pass this to the environment variable `SECRET_KEY`

    echo `openssl rand -base64 42`

    P7WUXOTAhVY83jwdOcKpWS3hqBHbWSeH5li6W7CrStfsXbK1Lv3O1wvs


<a id="orgf0f7648"></a>

# Environment Variables

The following is a template of the environment variables file that will be passed to the docker container when starting it.
When creating a Cyverse app, these would need to be passed as environment variables.
Let&rsquo;s call this file `env.local`

    cat env

    SECRET_KEY=
    MDH_SECRET=
    MDH_ACC_NAME=
    MDH_PROJECT_ID=
    MDH_SCHEMA=
    MDH_S3=
    SUPERSET_ADMIN_USER=
    SUPERSET_ADMIN_PASS=
    IPLANT_USER=


<a id="orgb67a79f"></a>

# Creating a volume

We will need to create a volume that can then be mounted to the running container so that the `superset.db` file can be persistently stored.

    docker volume create superset-cyverse
    # Check that the volume has been created.
    docker volume ls

    superset-cyverse
    DRIVER    VOLUME NAME
    local     superset-cyverse


<a id="org2eebd50"></a>

# Running the Container

Let&rsquo;s put it all together and go ahead and run this container. Here we will also pass the environment variables from `env.local` along with mounting the
volume we just created.


<a id="org275403d"></a>

## Running it in foreground [interactive / with output]

If you would like to create a container and then just start it, use this.


<a id="orgbac21dc"></a>

### Create the container

    docker create --name superset-cyverse -p 9088:9088 --env-file ./env.local -v superset-cyverse:/data-store/ nextgensh/superset-sf
    docker container ls -a | grep cyverse

    bfa5876d1c6b3639d0dfd7441e86b245b81b5da4bbb0ceed6865bac4a71dbe5e
    bfa5876d1c6b   nextgensh/superset-sf   "bash /bin/entry.sh"   Less than a second ago   Created                superset-cyverse


<a id="orgbe36282"></a>

### Start the container

You can start then start running the container using

    docker start superset-cyverse
    docker container ps | grep cyverse

    superset-cyverse
    bfa5876d1c6b   nextgensh/superset-sf   "bash /bin/entry.sh"   12 seconds ago   Up Less than a second   0.0.0.0:9088->9088/tcp   superset-cyverse


<a id="orgdb41442"></a>

### Cleaning up

    docker stop superset-cyverse
    docker container rm superset-cyverse


<a id="org27cc771"></a>

## Running it in background [non-interactive]

This is good for debugging and seeing what is going on. The `--rm` argument instructs docker to delete the container after this process is killed, while the `-it` starts docker in interactive mode.

    docker run --rm -it -p 9088:9088 --env-file ./env.local -v superset-cyverse:/data-store/ nextgensh/superset-sf

