FROM alpine:3.17
ARG MC_VERSION=RELEASE.2023-01-11T03-14-16Z
COPY make_backup.sh /usr/bin/make_backup.sh
RUN apk add --no-cache \
    postgresql15==15.4-r0 && \
    wget -q https://dl.min.io/client/mc/release/linux-amd64/archive/mc.$MC_VERSION -O /usr/bin/mc && \
    chmod +x /usr/bin/mc && \
    chmod +x /usr/bin/make_backup.sh

CMD [ "create_backup.sh" ]