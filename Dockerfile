ARG ARCH=library
FROM $ARCH/alpine:latest AS builder
MAINTAINER b3vis
ARG BORG_VERSION=1.1.13
ARG BORGMATIC_VERSION=1.5.8
RUN apk upgrade --no-cache \
    && apk add --no-cache \
    alpine-sdk \
    python3-dev \
    py3-pip \
    openssl-dev \
    lz4-dev \
    acl-dev \
    linux-headers \
    fuse-dev \
    attr-dev \
    && pip3 install --upgrade pip \
    && pip3 install --upgrade borgbackup==${BORG_VERSION} \
    && pip3 install --upgrade borgmatic==${BORGMATIC_VERSION} \
    && pip3 install llfuse

FROM $ARCH/alpine:latest
MAINTAINER b3vis
COPY entry.sh /entry.sh
RUN apk upgrade --no-cache \
    && apk add --no-cache \
    tzdata \
    sshfs \
    python3 \
    fuse \
    openssl \
    ca-certificates \
    lz4-libs \
    libacl \
    && rm -rf /var/cache/apk/* \
    && chmod 755 /entry.sh
VOLUME /mnt/source
VOLUME /mnt/borg-repository
VOLUME /etc/borgmatic.d
VOLUME /root/.config/borg
VOLUME /root/.ssh
VOLUME /root/.cache/borg
COPY --from=builder /usr/lib/python3.8/site-packages /usr/lib/python3.8/
COPY --from=builder /usr/bin/borg /usr/bin/
COPY --from=builder /usr/bin/borgfs /usr/bin/
COPY --from=builder /usr/bin/borgmatic /usr/bin/
COPY --from=builder /usr/bin/generate-borgmatic-config /usr/bin/
COPY --from=builder /usr/bin/upgrade-borgmatic-config /usr/bin/
CMD ["/entry.sh"]
