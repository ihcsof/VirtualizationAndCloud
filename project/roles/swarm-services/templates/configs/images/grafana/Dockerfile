FROM grafana/grafana-oss:10.2.2

USER root
# TODO install entrypoint dependencies
RUN apk add --no-cache netcat-openbsd curl jq ca-certificates
# TODO install entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

USER 1000
# TODO invoke our entrypoint
ENTRYPOINT ["/entrypoint.sh"]