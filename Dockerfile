# Alpine 3.24 ships ClamAV 1.4.6. Image 20251119095403 was built on
# Alpine 3.22 (ClamAV 1.4.3, flagged as outdated by freshclam).
FROM alpine:3.24

ARG BUILD_DATE
ARG VCS_REF
LABEL maintainer="James Hunt <images@huntprod.com>" \
      summary="Run ClamAV in a container" \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.vcs-url="https://github.com/filefrog/clamav.git" \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.schema-version="1.0.0"

EXPOSE 3310
VOLUME ['/var/lib/clamav']

RUN apk update \
 && apk add clamav-daemon clamav-libunrar \
            curl ca-certificates \
 && rm -rf /var/cache/apk/*

RUN mkdir /var/run/clamav \
 && chown clamav:clamav /var/run/clamav \
 && chown clamav:clamav /var/lib/clamav \
 && chmod 750 /var/run/clamav

# Daily host scan with a report mail (Excellence Cloud): crond runs scan.sh,
# which mails the clamdscan summary through SendGrid (send_email.py).
RUN apk add --no-cache python3 py3-pip dcron

ENV VIRTUAL_ENV=/app/venv
ENV PATH="$VIRTUAL_ENV/bin:$PATH"
RUN python3 -m venv $VIRTUAL_ENV
RUN pip3 install --no-cache-dir sendgrid==6.12.5

COPY . /
RUN chmod +x /scan.sh /start.sh
RUN echo "0 0 * * * /scan.sh >> /var/log/cron.log 2>&1" > /etc/crontabs/root

# start.sh starts crond, then clamd (via /clamav). The Kubernetes DaemonSet
# sets the same command explicitly.
ENTRYPOINT ["/start.sh"]
