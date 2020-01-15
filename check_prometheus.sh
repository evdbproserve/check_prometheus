#!/bin/bash

STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3
STATE_DEPENDENT=4

HOSTNAME=
PORT=
CHECK=

usage() {

# Real men do not read the instructions....

echo " "
echo "$0 - check for Promeutheus"
echo " "
echo "$0 [options] -h [hostname/ip] -p [port]"
echo " "
echo "Option		Meaning"
echo "-c		Check host before executing check"
echo " "
exit 4

}

check_req() {

# Requirements to run this check.
requirements=( curl nc )

for check in "${requirements[@]}"
do
	[ $(which $check) ] && continue
	echo "$check is required to run this check. Please install $check."
	exit 4
done


# Check if http:// or https:// is defined in hostname/IP
[[ "$HOSTNAME" != "https://"* ]] && [[ "$HOSTNAME" != "http://"* ]] && echo "Please use https://$HOSTNAME or http://$HOSTNAME" && exit 2


}

check_host() {

nc -zv -4 -w 1 ${HOSTNAME#*//} $PORT > /dev/null 2>&1
[ $? -gt 0 ] || return

echo "CRITICAL - Prometheus DOWN on $HOSTNAME using port $PORT"
exit 2


}


check_ready() {

# Ready check
result=$(curl -k --connect-timeout 2 $HOSTNAME:$PORT/-/ready 2>/dev/null)
[[ $result == *"Ready"* ]] && return

echo "CRITICAL - Prometheus is NOT ready on $HOSTNAME using port $PORT"
exit 2



}

check_health() {

# Health check
result=$(curl -k --connect-timeout 2 $HOSTNAME:$PORT/-/healthy 2>/dev/null)
[[ $result == *"Healthy"* ]] && return

echo "CRITICAL - Prometheus is NOT healthy on $HOSTNAME using port $PORT"
exit 2


}



while getopts “h:p:c?” OPTION
do
     case $OPTION in
         h)
             HOSTNAME=$OPTARG
             ;;
         p)
             PORT=$OPTARG
             ;;
         c)
             CHECK=true
             ;;
         ?)
             usage
             ;;
     esac
done

[ -z $PORT ] && usage
[ -z $HOSTNAME ] && usage

# Check if all required files are on the system
check_req

# Check if avaiability option is true
[ $CHECK ] && check_host

# Run the healty check(s)
check_ready
check_health

# If you are here, all checks are good and we can leave it a good feeling.
echo "OK - Prometheus is running like it should. All good!"
exit $STATE_OK
