FROM alpine:3.17

ARG MC_VERSION=RELEASE.2023-01-11T03-14-16Z

WORKDIR /opt

COPY ./medusa/* .
COPY ./vault-backup.sh .

RUN apk add --no-cache bash==5.2.15-r0 openssl==3.0.7-r2 && \
    wget -q https://dl.min.io/client/mc/release/linux-amd64/archive/mc.$MC_VERSION -O /usr/bin/mc && \
    chmod +x /usr/bin/mc && \
    tar -xf medusa_0.4.1_linux_amd64.tar.gz && \
    cp medusa /usr/bin/medusa && \
    chmod +x /usr/bin/medusa && \
    chmod +x ./vault-backup.sh 

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ENTRYPOINT [ "/opt/vault-backup.sh" ]