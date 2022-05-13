#!/bin/bash

_dir="$(dirname "$0")"

source "$_dir/config.sh"

# Strip only the top domain to get the zone id
DOMAIN=$(expr match "$CERTBOT_DOMAIN" '.*\.\(.*\..*\)')
[[ -z "$DOMAIN" ]] && DOMAIN="$CERTBOT_DOMAIN"

# Strip subdomains part if present
SUBDOMAIN=$(expr match "$CERTBOT_DOMAIN" '\(.*\)\..*\..*')

# Create TXT record
[[ -z "$SUBDOMAIN" ]] && CREATE_DOMAIN="_acme-challenge" || CREATE_DOMAIN="_acme-challenge.$SUBDOMAIN"

echo "Creating domain at `date -R` for CERTBOT_DOMAIN: $CERTBOT_DOMAIN, DOMAIN: $DOMAIN, SUBDOMAIN: $SUBDOMAIN, CREATE_DOMAIN: $CREATE_DOMAIN"

RECORD_ID=$(curl -s -X POST "https://pddimp.yandex.ru/api2/admin/dns/add" \
     -H "PddToken: $API_KEY" \
     -d "domain=$DOMAIN&type=TXT&content=$CERTBOT_VALIDATION&ttl=3600&subdomain=$CREATE_DOMAIN" \
	 | python -c "import sys,json;print(json.load(sys.stdin)['record']['record_id'])")
	
# Save info for cleanup
if [ ! -d /tmp/CERTBOT_$CERTBOT_DOMAIN ];then
        mkdir -m 0700 /tmp/CERTBOT_$CERTBOT_DOMAIN
fi

echo $RECORD_ID > /tmp/CERTBOT_$CERTBOT_DOMAIN/RECORD_ID

echo "Created RECORD_ID: $RECORD_ID"

# Sleep to make sure the change has time to propagate over to DNS
sleep 60

# Sleep to make sure the change has time to propagate over to DNS (180 min)
c_time=0
end_time=$[3600*3]
while [ "$c_time" -le "$end_time" ]; do
        if [ `dig $CREATE_DOMAIN.$DOMAIN TXT +short @dns1.yandex.net | grep $CERTBOT_VALIDATION` ]; then
		echo "@dns1.yandex.net is OK at `date -R`"
                sleep 5
                if [ `dig $CREATE_DOMAIN.$DOMAIN TXT +short @dns2.yandex.net | grep $CERTBOT_VALIDATION` ]; then
			echo "@dns2.yandex.net is OK at `date -R`"
                        sleep 5
                        if [ `dig $CREATE_DOMAIN.$DOMAIN TXT +short @8.8.8.8 | grep $CERTBOT_VALIDATION` ]; then
				echo "All dns is OK at `date -R`"
                                sleep 5
                                break
                        else
                                sleep 50
                                c_time=$[c_time+50]
                        fi
                else
                        sleep 55
                        c_time=$[c_time+55]
                fi
        else
                sleep 60
                c_time=$[c_time+60]
        fi
done

left_time=$[end_time-c_time]
if [ "$left_time" -ge 0 ]; then
	echo "Seconds left: $left_time, sleeping"
	sleep $left_time
fi
