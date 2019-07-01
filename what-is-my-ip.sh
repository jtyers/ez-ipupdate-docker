#!/bin/bash

# what-is-my-ip.sh
#
# Retrieves your public IP using icanhazip.com, dyn.com and whatismyip.com (in this order). The
# script caches your IP in $HOME/.my-ip-address and will use that value if it's less than 30 mins
# old. The caching is there to avoid repeated calls to the script hitting rate limits and errors.
#
# -f    if -f is specified, the cache file is ignored; this forces the script to query your IP
#       via the external services above; use sparingly to avoid rate limits!
#

set -eu

cacheFile="$HOME/.my-ip-address"

# returns 0 if cache file is out of date or missing; 1 if it is < 30mins old
cacheOutOfDate() {
	[ ! -f "$cacheFile" ] && return 0

	# empty file means out of date
	[ -z "`cat $cacheFile`" ] && return 0

	cmd="find `dirname $cacheFile` -maxdepth 1 -mindepth 1 -mmin 30 -name `basename $cacheFile`"

	# no output = file not modified in last 24hrs
	[ -z "`$cmd 2>/dev/null`" ] || return 0
	
	return 1
}

tryPublicIp() {
  case "$1" in
    dyn)
      publicIp=`curl -m 5 -fs http://checkip.dyn.com/ | \
        egrep -oE '([0-9]+\.|[0-9])+'`

      ;;

    whatismyip)
      # whatismyip.com only accepts agent strings that look like real browsers, so we mimic one of those...
      AGENT="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/69.0.3497.100 Safari/537.36"
      
      publicIp=`curl -fs -A "$AGENT" https://www.whatismyip.com/ | \
        grep 'Your Public IPv4 is: ' | \
        sed -e 's#^Your Public IPv4 is: ##g' -e 's#</li>$##'`
      ;;

    icanhazip)
      publicIp=`curl -m 5 -fs https://icanhazip.com/`
      ;;

    *)
      echo "unknown public IP type: $1" >&2
      exit 1
      ;;
  esac
	
  # now, there is a bug in checkip.dyn.com that sometimes causes the IP
	# of one of the gateways to be returned rather than our public IP, so
	# we use whatismyip as a fallback
	isLocal=`egrep -E '^192\.168\.|^10\.|^169\.254|^172\.' <<<"$publicIp" || true`

  if [ -n "$isLocal" ]; then
    echo "${1} returned a local IP address" >&2
    exit 1
  fi

  echo "$publicIp"
}

################
# the old way...
################


if [ "${1:-}" == "-f" ] || cacheOutOfDate; then
	echo "cache out of date, looking up address..." >&2

  publicIp=""
  for ipType in icanhazip dyn whatismyip; do
    set +e
    publicIp=`tryPublicIp $ipType`
    [ -n "$publicIp" ] && break
    set -e
  done

  if [ -z "$publicIp" ]; then
    echo "could not get public IP" >&2
    exit 1
  fi

	echo $publicIp > $cacheFile

	cat $cacheFile

else
	# exit with 127 if the cache was not out of date
	echo "cache in date (exit code 127)" >&2
	
	cat $cacheFile
	exit 127

fi

