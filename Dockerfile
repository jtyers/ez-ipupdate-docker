FROM alpine

RUN apk add -U ez-ipupdate curl bash

COPY ez-ipupdate.conf /etc/ez-ipupdate.conf
COPY run-update.sh /usr/local/bin/run-update.sh
COPY what-is-my-ip.sh /usr/local/bin/what-is-my-ip.sh

ENTRYPOINT [ "/usr/local/bin/run-update.sh" ]
