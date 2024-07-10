FROM ubuntu:22.04
MAINTAINER Shravan Aras <shravanaras@arizona.edu>

USER root

RUN apt-get update &&\
    apt-get install -y \
        build-essential \
        libssl-dev \
        libffi-dev \
        libsasl2-dev \
        libldap2-dev \
        zlib1g-dev \
        libreadline-dev \
        libsqlite3-dev \
        git \
        libbz2-dev \
        default-libmysqlclient-dev \
        wget \
        curl

# Let's install the specific version of python we need.
# We are going to compile and install python. This will take time when building the image
WORKDIR /tmp/
RUN wget https://www.python.org/ftp/python/3.11.4/Python-3.11.4.tgz
RUN tar -xvf Python-3.11.4.tgz
WORKDIR /tmp/Python-3.11.4/
RUN ./configure --enable-optimizations && make && make install

# Create a non-root user to install the python repositories.
#RUN adduser --disabled-password --gecos "superset" --uid 1310 superset
#RUN passwd -d superset

# Add sudo to superset user
RUN apt-get install sudo 

#RUN usermod -a -G sudo superset
#
# Install crontab and configure so we can backup the metadata store periodically.
RUN apt-get install -y cron
COPY backup-cron /etc/cron.d/backup-cron
RUN chmod 0644 /etc/cron.d/backup-cron && crontab /etc/cron.d/backup-cron

RUN mkdir /opt/superset/ 
COPY scripts/backup.sh /opt/superset/backup.sh

# Create the directory structure inside /var/ to store superset metadata.
RUN mkdir -p /var/superset/
#    && chown superset:superset /var/superset/

RUN mkdir -p /var/superset-home/

WORKDIR /var/superset-home
RUN mkdir packages/
COPY packages/apache-superset-0.0.0.dev0.tar.gz packages/
RUN mkdir configs/
COPY configs/superset_config.py configs/

#USER superset
#WORKDIR /home/superset

# Install the custom version of superset we just pulled in.
RUN pip3 install packages/apache-superset-0.0.0.dev0.tar.gz
# sqlparse needs to be downgraded to avoid the `sqlparse.keywords.FLAGS not found` error.
# Which comes starting sqlparse=0.4.4
RUN pip3 install sqlparse==0.5.0
# Install the Mysql driver.
# RUN pip install mysqlclient
# Install the pyathena driver.
RUN pip3 install PyAthena==3.8.3
# Install sensorfabric, on whose fragile shoulders everything rests.
RUN pip3 install sensorfabric==3.1.0

#ENV PATH=$PATH:/home/superset/.local/bin

# entry.sh will need the following environment variables to be correctly
# passed / set for them to work.
# 1. SECRET_KEY = ....
# 2. SUPERSET_ADMIN_PASS = ....
# 3. SUPERSET_ADMIN_USER = ....

ENV FLASK_APP=superset
ENV SUPERSET_CONFIG_PATH=/var/superset-home/configs/superset_config.py

EXPOSE 9088

COPY entry.sh /bin
ENTRYPOINT ["bash", "/bin/entry.sh"]
