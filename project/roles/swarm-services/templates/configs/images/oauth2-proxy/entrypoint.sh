#!/bin/sh

echo "Initializing oauth2-proxy's dependencies"

sleep 50 

until [ "$(curl -k -s -o /dev/null -w '%{http_code}' https://auth.vcc.local/)" -eq 200 ]; do
  echo 'Waiting for authentication server'
  sleep 5
done

until [ "$(curl -k -s -o /dev/null -w '%{http_code}' https://auth.vcc.local/realms/vcc)" -eq 200 ]; do
  echo 'Waiting for authentication server realms'
  sleep 2
done

keycloakAdminToken() {
  curl -k -X POST https://auth.vcc.local/realms/master/protocol/openid-connect/token \
    --data-urlencode "username=$KEYCLOAK_ADMIN" \
    --data-urlencode "password=$KEYCLOAK_ADMIN_PASSWORD" \
    --data-urlencode 'grant_type=password' \
    --data-urlencode 'client_id=admin-cli' | jq -r '.access_token'
}

prometheus_client_id=$(curl -k -H "Authorization: Bearer $(keycloakAdminToken)" https://auth.vcc.local/admin/realms/vcc/clients?clientId=prometheus | jq -r '.[0].id')
prometheus_client_secret=$(curl -k -H "Authorization: Bearer $(keycloakAdminToken)" -X POST https://auth.vcc.local/admin/realms/vcc/clients/${prometheus_client_id}/client-secret | jq -r '.value')

# run original entrypoint
/bin/oauth2-proxy "$@" "--client-secret" "${prometheus_client_secret}" "--cookie-secret" "$OAUTH2_PROXY_COOKIE_SECRET"