FROM ubuntu:focal
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Australia/Brisbane

## xpra
RUN \
    # ensure the SSL certificates are up to date
    apt-get update && \
    apt-get install -y \
        ca-certificates \
        gnupg \
        wget \
        && \
    wget -q https://xpra.org/gpg.asc -O- | gpg --dearmor > /usr/share/keyrings/xpra-archive-keyring.gpg && \
    echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/xpra-archive-keyring.gpg] https://xpra.org/ focal main' > /etc/apt/sources.list.d/xpra.list && \
    apt-get update && \
    apt-get install -y -f \
        xpra \
        xpra-html5

## chrome
RUN \
    apt-get update && \
    apt-get install -y \
        fonts-liberation \
        xdg-utils \
        && \
    cd /tmp && \
    wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    dpkg -i google-chrome-stable_current_amd64.deb

## add chrome user
RUN \
    groupadd \
        --system \
        --gid 1000 \
        chrome \
        && \
    useradd \
        --create-home \
        --home-dir=/config \
        --shell=/bin/bash \
        --uid 1000 \
        --gid 1000 \
        chrome

ENV XPRA_ACK_TOLERANCE=5000
ENV XPRA_ACK_JITTER=5000
EXPOSE 3000
VOLUME /config

USER chrome
WORKDIR /config
ENTRYPOINT [ "xpra" ]
CMD [ "start", "--start=google-chrome --no-sandbox --no-first-run --user-data-dir=/config/profile", "--bind-tcp=0.0.0.0:3000", "--daemon=no", "--resize-display=yes", "--desktop-scaling=auto"]