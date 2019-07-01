#!/bin/sh

# runs ez-ipupdate in a loop

set -u

while true; do
	# run what-is-my-ip.sh; which will use checkip.dyn.com / whatismyip.com;
	# it stores the results in a cache file which is not allowed to be updated
	# more than once per 30 mins; if the cache has not changed since the last
	# run the script returns non-zero; it only returns success (zero) if it
	# got a new IP address

	IP=`what-is-my-ip.sh`
	ret=$?

	if [ $ret -eq 0 ]; then
		echo "`date` updating IP to $IP"
		ez-ipupdate -c /etc/ez-ipupdate.conf -a "$IP"
	fi
	
	sleep 300 # 5 mins

done
