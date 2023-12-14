#!/bin/bash
set -e
first_run=true

# if [[ -f "/etc/ldap/ldap_populated" ]]; then
#     first_run=false
# fi

# Wait until 'LDAP started and listens on port 389'.
while [ -z "`netstat -tln | grep 389`" ]; do
  echo 'Waiting for LDAP to start ...'
  sleep 1
done
echo 'LDAP started.'

dc_string=""
IFS="."; declare -a dc_parts=($SLAPD_DOMAIN); unset IFS

for dc_part in "${dc_parts[@]}"; do
	dc_string="$dc_string,dc=$dc_part"
done

echo "DC string: $dc_string"

if [[ "$first_run" == "true" ]]; then
	echo "Loading prepopulate data."
	if [[ -d "/etc/ldap/prepopulate/data/" ]]; then
		for file in `ls /etc/ldap/prepopulate/data/*.ldif`; do
			ldapadd -x -D cn=admin$dc_string -w $SLAPD_PASSWORD -f "$file"
		done
	fi
	touch /etc/ldap/ldap_populated
fi
