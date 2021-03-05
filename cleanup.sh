#!/bin/bash

_dir="$(dirname "$0")"

source "$_dir/config.sh"

# Strip only the top domain to get the zone id
DOMAIN=$(expr match "$CERTBOT_DOMAIN" '.*\.\(.*\..*\)')
[[ -z "$DOMAIN" ]] && DOMAIN="$CERTBOT_DOMAIN"

if [ -f /tmp/CERTBOT_$CERTBOT_DOMAIN/RECORD_ID ]; then
        RECORD_ID=$(cat /tmp/CERTBOT_$CERTBOT_DOMAIN/RECORD_ID)
        rm -f /tmp/CERTBOT_$CERTBOT_DOMAIN/RECORD_ID
fi

# Remove the challenge TXT record from the zone
if [ -n "${RECORD_ID}" ]; then
	
	RESULT=$(curl -s -X POST "https://pddimp.yandex.ru/api2/admin/dns/del" \
     -H "PddToken: $API_KEY" \
     -d "domain=$DOMAIN&record_id=$RECORD_ID" \
	 | python -c "import sys,json;print(json.load(sys.stdin)['success'])")
	
	echo $RESULT 
fi
