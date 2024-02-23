FROM codeberg.org/forgejo/forgejo:1.21
# TODO install entrypoint dependencies
RUN apk add --no-cache su-exec netcat-openbsd curl jq ca-certificates

# TODO install and use new entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]