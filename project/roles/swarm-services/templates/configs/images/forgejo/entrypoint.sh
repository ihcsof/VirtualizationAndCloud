#!/bin/sh

# as the cli does not run as root
# you need to wrap the forgejo command to run as the `git` user
forgejo_cli() {
  # TODO
  # run the forgejo command as the `git` user
  su-exec "$USER_UID":"$USER_GID" forgejo "$@"
}

# TASK 37
# TODO wait until database is alive (port 5432 replies), using netcat (it should be installed)

echo "Initializing forgejo's dependencies"

 # setting workdir for gitea
export GITEA_WORK_DIR=/tmp/test-gitea

sleep 50 #postgres is really slow :/

nc -z database.vcc.local 5432
until [ "$?" -eq 0 ]; do
  echo "database still unreachable"
  sleep 5
  nc -z database.vcc.local 5432
done

echo "migrating db"
# TODO prepare database (`forgejo migrate` cli command)
forgejo_cli "migrate"

# TODO create admin user (if it does not exists already)
# use `forgejo admin user list` and `forgejo admin user create`
if [ $(forgejo_cli "admin" "user" "list" "--admin" | wc -l) -lt 2 ] ; then
    echo "No admin user found. Creating a new admin user..."

    forgejo_cli "admin" "user" "create" "--username" "$FORGEJO_ADMIN" "--password" "$FORGEJO_ADMIN_PASSWORD" "--email" "forgejo@mail.com" "--admin" "true"

    echo "Admin user created successfully."
fi

echo "starting forgejo"

# start forgejo (in background)
/bin/s6-svscan /etc/s6 "$@" &

# TODO wait until forgejo is active (use curl, check for 200 code)
until [ "$(curl -s -o /dev/null -w '%{http_code}' localhost:3000)" -eq 200 ]; do # could change url to localhost if we see it's pointless
  echo 'Waiting for forgejo server'
  sleep 5
done

# TODO wait until authentication server is alive (use curl, check for 200 code)
until [ "$(curl -k -s -o /dev/null -w '%{http_code}' https://auth.vcc.local/)" -eq 200 ]; do
  echo 'Waiting for authentication server'
  sleep 5
done

# TODO wait until https://auth.vcc.local/realms/vcc is alive (use curl, check for 200 code)
until [ "$(curl -k -s -o /dev/null -w '%{http_code}' https://auth.vcc.local/realms/vcc)" -eq 200 ]; do
  echo 'Waiting for authentication server realms'
  sleep 2
done

# wait until self-signed certificate file exists
until [ -f /usr/local/share/ca-certificates/server.crt ]; do
  echo 'Waiting for certificate'
  sleep 1
done

# TODO update the system list of accepted CA certificates
# Debian-based systems (e.g., Ubuntu)
update-ca-certificates

#
# Download from keycloak forgejo's client id and secret 
#
keycloakAdminToken() {
  curl -k -X POST https://auth.vcc.local/realms/master/protocol/openid-connect/token \
    --data-urlencode "username=$KEYCLOAK_ADMIN" \
    --data-urlencode "password=$KEYCLOAK_ADMIN_PASSWORD" \
    --data-urlencode 'grant_type=password' \
    --data-urlencode 'client_id=admin-cli' | jq -r '.access_token'
}

# echo "$(keycloakAdminToken)" # lol

forgejo_client_id=$(curl -k -H "Authorization: Bearer $(keycloakAdminToken)" https://auth.vcc.local/admin/realms/vcc/clients?clientId=forgejo | jq -r '.[0].id')
forgejo_client_secret=$(curl -k -H "Authorization: Bearer $(keycloakAdminToken)" -X GET https://auth.vcc.local/admin/realms/vcc/clients/${forgejo_client_id}/client-secret | jq -r '.value')

# TODO maybe it's not that cool to put secrets in your logs :)
# echo "Forgejo client id in keycloak is ${forgejo_client_id}"
# echo "Forgejo client secret in keycloak is ${forgejo_client_secret}"

# TODO setup authentication (if it does not exist)
# use `forgejo admin auth add-oauth`
#   --auto-discover-url is https://auth.vcc.local/realms/vcc/.well-known/openid-configuration
#   --provider is openidConnect

AUTO_DISCOVER_URL="https://auth.vcc.local/realms/vcc/.well-known/openid-configuration"
PROVIDER="openidConnect"

# Check if authentication setup exists
if forgejo_cli "admin" "auth" "list" | grep -q "$PROVIDER"; then
    echo "Authentication setup already exists."
else
    echo "Setting up authentication..."

    # Set up authentication using forgejo admin auth add-oauth
    forgejo_cli "admin" "auth" "add-oauth" "--name" "keycloak" "--auto-discover-url" "$AUTO_DISCOVER_URL" "--provider" "$PROVIDER" \
      "--key" "forgejo" "--secret" "$forgejo_client_secret"
    echo "Authentication setup completed."
fi

# wait forever
wait
