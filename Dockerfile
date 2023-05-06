FROM ubuntu
MAINTAINER Shravan Aras <shravanaras@arizona.edu>

USER root

RUN apt-get update &&\
    apt-get install -y \
        build-essential \
        libssl-dev \
        libffi-dev \
        python3-dev \
        python3-pip \
        libsasl2-dev \
        libldap2-dev \
        default-libmysqlclient-dev

# Create a non-root user to install the python repositories.
RUN adduser --disabled-password --gecos "superset" --uid 1310 superset

USER superset
WORKDIR /home/superset

RUN pip install apache-superset
# sqlparse needs to be downgraded to avoid the `sqlparse.keywords.FLAGS not found` error.
# Which comes starting sqlparse=0.4.4
RUN pip install sqlparse==0.4.3
# Install the Mysql driver.
RUN pip install mysqlclient
# Install the pyathena driver.
RUN pip install PyAthena

ENV PATH=$PATH:/home/superset/.local/bin

# entry.sh will need the following environment variables to be correctly
# passed / set for them to work.
# 1. SUPERSET_SECRET_KEY = ....
# 2. SUPERSET_ADMIN_PASS = ....
# 3. SUPERSET_ADMIN_USER = ....

ENV FLASK_APP=superset

EXPOSE 9088

COPY entry.sh /bin
ENTRYPOINT ["bash", "/bin/entry.sh"]
