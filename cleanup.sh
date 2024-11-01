#!/bin/bash

_dir="$(dirname "$0")"
source "$_dir/config.sh"

# Strip only the top domain to get the zone id
DOMAIN=$(expr match "$CERTBOT_DOMAIN" '.*\.\(.*\..*\)')
[[ -z "$DOMAIN" ]] && DOMAIN="$CERTBOT_DOMAIN"

# Remove the challenge TXT record from the zone
remove_record() {
	RECORD_ID="$1"
	if [ -n "${RECORD_ID}" ]; then
		# https://yandex.ru/dev/api360/doc/ref/DomainDNSService/DomainDNSService_Delete
		RESULT=$(curl -s -X DELETE "https://api360.yandex.net/directory/v1/org/$ORG_ID/domains/$DOMAIN/dns/$RECORD_ID" \
			-H "Authorization: OAuth $OAUTH_TOKEN")

		if [[ "$RESULT" == "{}" ]]; then
			echo "delete ${RECORD_ID}: ok"
		else
			echo $RESULT
		fi
	fi
}

if [ -f /tmp/CERTBOT_$CERTBOT_DOMAIN/RECORD_ID ]; then
	while read LINE; do
		remove_record $LINE
	done < /tmp/CERTBOT_$CERTBOT_DOMAIN/RECORD_ID

	rm -f /tmp/CERTBOT_$CERTBOT_DOMAIN/RECORD_ID
fi
