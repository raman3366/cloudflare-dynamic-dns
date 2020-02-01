#!/bin/bash

# Use your cloudflare API credentials
cloudflare_auth_email=******@gmail.com
cloudflare_auth_key=*************************************

# Point to your Apache or NGINX Installation conf files directory
cd /etc/apache2/sites-enabled
rawdomainsconf=(*)
nod=${#rawdomainsconf[@]}
echo " "

for((i=0; i<$nod; i++))
do
	a=${rawdomainsconf[i]}
	rawdomains[i]=${a::-5}
	if [[ ${rawdomains[i]} == www.* ]]
	then
		b=${rawdomains[i]}
		domain=${b:4}
		echo "Domain Name: "$domain" Do you want to update A record for this domain? (y/n)"
		echo " "
		read decision
		if [[ $decision == "y" ]]
		then

			# Cloudflare zone is the zone which holds the record
			zone=$domain
			# dnsrecord is the A record which will be updated
			dnsrecord=$zone

			# Get the current external IP address
			ip=$(curl -s -X GET https://checkip.amazonaws.com)

			echo " "
			echo "Current IP is $ip"

			# if here, the dns record needs updating

			# get the zone id for the requested zone
			zoneid=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones?name=$zone&status=active" \
			  -H "X-Auth-Email: $cloudflare_auth_email" \
			  -H "X-Auth-Key: $cloudflare_auth_key" \
			  -H "Content-Type: application/json" | jq -r '{"result"}[] | .[0] | .id')

			echo " "
			echo "Zone ID for $zone is $zoneid"

			# get the dns record id
			dnsrecordid=$(curl -s -X GET "https://api.cloudflare.com/client/v4/zones/$zoneid/dns_records?type=A&name=$dnsrecord" \
			  -H "X-Auth-Email: $cloudflare_auth_email" \
			  -H "X-Auth-Key: $cloudflare_auth_key" \
			  -H "Content-Type: application/json" | jq -r '{"result"}[] | .[0] | .id')

			echo " "
			echo "DNS Record ID for $dnsrecord is $dnsrecordid"

			# update the record
			updatestatus=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$zoneid/dns_records/$dnsrecordid" \
			  -H "X-Auth-Email: $cloudflare_auth_email" \
			  -H "X-Auth-Key: $cloudflare_auth_key" \
			  -H "Content-Type: application/json" \
			  --data "{\"type\":\"A\",\"name\":\"$dnsrecord\",\"content\":\"$ip\",\"ttl\":1,\"proxied\":false}")
			  
			if [[ $updatestatus == *"\"success\":false"* ]]; then
				echo " "
				echo "DNS update failed."
				echo " "
				exit 1 
			else
				echo " "
				echo "DNS update successfull"
				echo " "
			fi

			echo "A record updated for "$domain
			echo " "
			echo "-----------------------------------------------"
			echo " "
		else
			echo " "
			echo $domain" skipped."
			echo " "
			echo "-----------------------------------------------"
			echo " "
		fi
	fi
done
echo " "
echo "Script Completed"
