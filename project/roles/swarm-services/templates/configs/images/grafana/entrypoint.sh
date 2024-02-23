#!/bin/sh

echo "Initializing grafana's dependencies"

sleep 50 #postgres is really slow :/

nc -z database.vcc.local 5432
until [ "$?" -eq 0 ]; do
  echo "database still unreachable"
  sleep 5
  nc -z database.vcc.local 5432
done

# TODO wait until authentication server is alive (use curl, check for 200 code)
until [ "$(curl -k -s -o /dev/null -w '%{http_code}' https://auth.vcc.local/)" -eq 200 ]; do
  echo 'Waiting for authentication server'
  sleep 5
done

# TODO wait until https://auth.vcc.local/realms/vcc is alive (use curl, check for 200 code)
until [ "$(curl -k -s -o /dev/null -w '%{http_code}' https://auth.vcc.local/realms/vcc)" -eq 200 ]; do
  echo 'Waiting for authentication server realms'
  sleep 5
done

# wait until self-signed certificate file exists
until [ -f /usr/local/share/ca-certificates/server.crt ]; do
  echo 'Waiting for certificate'
  sleep 1
done

# TODO update the system list of accepted CA certificates
update-ca-certificates

#
# Download from keycloak grafana's client id and secret 
#
keycloakAdminToken() {
  curl -k -X POST https://auth.vcc.local/realms/master/protocol/openid-connect/token \
    --data-urlencode "username=$KEYCLOAK_ADMIN" \
    --data-urlencode "password=$KEYCLOAK_ADMIN_PASSWORD" \
    --data-urlencode 'grant_type=password' \
    --data-urlencode 'client_id=admin-cli' | jq -r '.access_token'
}

grafana_client_id=$(curl -k -H "Authorization: Bearer $(keycloakAdminToken)" https://auth.vcc.local/admin/realms/vcc/clients?clientId=grafana | jq -r '.[0].id')
grafana_client_secret=$(curl -k -H "Authorization: Bearer $(keycloakAdminToken)" -X POST https://auth.vcc.local/admin/realms/vcc/clients/${grafana_client_id}/client-secret | jq -r '.value')

# TODO maybe it's not that cool to put secrets in your logs :)
# echo "Grafana client id in keycloak is ${grafana_client_id}"
# echo "Grafana client secret in keycloak is ${grafana_client_secret}"

# TODO setup authentication
# Set environment variables for Grafana authentication
export GF_AUTH_GENERIC_OAUTH_CLIENT_ID="grafana"
export GF_AUTH_GENERIC_OAUTH_CLIENT_SECRET="${grafana_client_secret}"
export GF_AUTH_GENERIC_OAUTH_SCOPES="openid profile email roles"
export GF_AUTH_GENERIC_OAUTH_AUTH_URL=https://auth.vcc.local/realms/vcc/protocol/openid-connect/auth
export GF_AUTH_GENERIC_OAUTH_TOKEN_URL=https://auth.vcc.local/realms/vcc/protocol/openid-connect/token
export GF_AUTH_GENERIC_OAUTH_API_URL=https://auth.vcc.local/realms/vcc/protocol/openid-connect/userinfo
export GF_AUTH_GENERIC_OAUTH_ENABLED=true
export GF_AUTH_GENERIC_OAUTH_ALLOW_SIGN_UP=true
export GF_AUTH_GENERIC_OAUTH_NAME=Keycloak
export GF_AUTH_GENERIC_OAUTH_TLS_SKIP_VERIFY_INSECURE=true

export GF_AUTH_GENERIC_OAUTH_ALLOW_ASSIGN_GRAFANA_ADMIN=true # needed to assign admin role to users
# this made us waste like 10 hours of debugging:
export GF_AUTH_GENERIC_OAUTH_ROLE_ATTRIBUTE_PATH="contains(realm_access.roles[*], 'vcc-admin') && 'GrafanaAdmin' || contains(realm_access.roles[*], 'Editor') && 'Editor' || 'Viewer'"

export GF_SERVER_DOMAIN=mon.vcc.local
export GF_SERVER_ROOT_URL=https://mon.vcc.local

# enable metrics
export GF_METRICS_ENABLED=true

# relaunch original
exec /run.sh "$@"
