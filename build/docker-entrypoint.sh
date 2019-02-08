#! /bin/sh

set -e

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
PURPLE='\033[1;34m'
NC='\033[0m'

CERTFILE=/astmanproxy/astmanproxy.pem


echo ""
echo -e "${PURPLE}----------------------------------------------------------------------------${NC}"
echo -e "${PURPLE} Checking SSL certificate status...   ${NC}"
echo -e "${PURPLE}----------------------------------------------------------------------------${NC}"
echo ""

# at first, we check if a ssl cert for astmanproxy is already existing. If not we will now generate one
echo -e "${YELLOW}Checking for existing SSL certificate at /etc/asterisk/astmanproxy.pem${NC}"

if [ ! -f $CERTFILE ]; then \
	echo -e "${RED}  --> Seems like there is no ssl cert. I will now create one for you now${NC}"
    echo ""
	SERIAL=`date "+%Y%m%d%H%M%S"`; 
	/usr/bin/openssl req -newkey rsa:$SSL_KEY_SIZE -keyout /tmp/astmanproxy-ssl.key -nodes -x509 -days 365 -out /tmp/astmanproxy-ssl.crt -set_serial $SERIAL -config /etc/asterisk/astmanproxy-ssl.conf
	cat /tmp/astmanproxy-ssl.key /tmp/astmanproxy-ssl.crt >  /etc/asterisk/astmanproxy.pem
    rm /tmp/astmanproxy-ssl.*
else
	echo "${GREEN}  --> Found a certificate. Nothing to do here.${NC}"
fi

echo ""
echo ""

# then we check if the cert is still valid for more than one day. If not - we create a new one (just to be sure we don't start a container that will soon break)!
echo -e "${YELLOW}Checking if the SSL certificate is at least valid for 24 more hours${NC}"
if [ ! "openssl x509 -checkend 86400 -noout -in /etc/asterisk/astmanproxy.pem" ]
then
	echo -e "${RED}  --> Seems like the existing cert will not be valid for the next 24 hours. Creating a new one now${NC}"
    echo ""
	SERIAL=`date "+%Y%m%d%H%M%S"`; 
	/usr/bin/openssl req -newkey rsa:$SSL_KEY_SIZE -keyout /tmp/astmanproxy-ssl.key -nodes -x509 -days 365 -out /tmp/astmanproxy-ssl.crt -set_serial $SERIAL -config /etc/asterisk/astmanproxy-ssl.conf
	cat /tmp/astmanproxy-ssl.key /tmp/astmanproxy-ssl.crt >  /etc/asterisk/astmanproxy.pem
    rm /tmp/astmanproxy-ssl.*
else
	echo -e "${GREEN}  --> Yupp. That seems to be valid. Nothing to do here.${NC}"
fi


# then we start astmanproxy
echo ""
echo -e "${PURPLE}----------------------------------------------------------------------------${NC}"
echo -e "${PURPLE} Starting astmanproxy now ...${NC}"
echo -e "${PURPLE}----------------------------------------------------------------------------${NC}"
echo ""

exec "$@"
