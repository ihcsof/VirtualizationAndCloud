FROM quay.io/oauth2-proxy/oauth2-proxy:v7.5.1

USER root
# install entrypoint dependencies
RUN apk add --no-cache netcat-openbsd curl jq
# install entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# invoke entrypoint
ENTRYPOINT ["/entrypoint.sh"]