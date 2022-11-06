#!/bin/sh
echo
echo " Synapse first user password reset"
echo
if [ "$(uname -n)" = "synapse.embassy" ]; then
    query() {
        sqlite3 /data/homeserver.db "$*"
    }
    password=$(cat /dev/urandom | base64 | head -c 16)
    hashed_password=$(hash_password -p "$password" -c "/data/homeserver.yaml")
    first_user_name=$(query "select name from users where creation_ts = (select min(creation_ts) from users) limit 1;")
    query "update users set password_hash=\"$hashed_password\" where name=\"$first_user_name\""
    echo "Here is your new password: $password"
    echo
    echo "Please store it in your Vaultwarden this time."
    echo
else
    echo "Run this only inside synapse.embassy service"
    echo
    echo "SSH in to your Embassy and run:"
    echo "sudo docker exec -it synapse.embassy sh"
    echo
fi
