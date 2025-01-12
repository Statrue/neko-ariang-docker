FROM alpine:latest

ARG ARIA_VERSION
ARG ARIANG_VERSION

LABEL maintainer="NekoRush" \
    name="neko-ariang" \
    description="Aria2 downloader and AriaNg webui Docker image based on Alpine Linux" \
    aria2.version=$ARIA_VERSION \
    ariang.version=$ARIANG_VERSION

RUN apk update && apk add --no-cache --update \
    aria2 \
    nginx \
    wget \
    unzip \
    supervisor \
    bash \
    curl

RUN mkdir -p /usr/share/nginx/html/ariang \
    && wget --no-check-certificate https://github.com/mayswind/AriaNg/releases/download/${ARIANG_VERSION}/AriaNg-${ARIANG_VERSION}.zip -O /tmp/ariang.zip \
    && unzip /tmp/ariang.zip -d /usr/share/nginx/html/ariang \
    && rm /tmp/ariang.zip

COPY nginx.conf /etc/nginx/nginx.conf
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY aria2.conf /config/aria2.conf
COPY update-trackers.cron /etc/cron.d/update-trackers.cron
COPY update-trackers.sh /usr/local/bin/update-trackers.sh

RUN mkdir -p /downloads
RUN touch /config/aria2.session
RUN chmod +x /usr/local/bin/update-trackers.sh
RUN chmod +x /etc/cron.d/update-trackers.cron && crontab /etc/cron.d/update-trackers.cron

VOLUME /downloads
VOLUME /config

EXPOSE 6880

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]