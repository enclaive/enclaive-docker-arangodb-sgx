FROM ubuntu:jammy

RUN apt-get update \
    && apt-get install -y --no-install-recommends gnupg2 wget ca-certificates \
    && wget -qO - https://download.arangodb.com/arangodb39/DEBIAN/Release.key | gpg --dearmor > /etc/apt/trusted.gpg.d/arangodb-com-3.9.gpg \
    && echo 'deb https://download.arangodb.com/arangodb39/DEBIAN/ /' > /etc/apt/sources.list.d/arangodb.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends arangodb3=3.9.2-1

RUN apt-get install -y --no-install-recommends fswatch xxd binutils

ENTRYPOINT [ "/usr/sbin/arangod", "--server.endpoint=tcp://0.0.0.0:8529" ]
