#!/bin/bash

usage()
{
    echo
    echo "usage: cltest -u <API URL>"
    echo "              -a <admin email>"
    echo "              [-N <root namespace>]"
    echo "                  root namespace"
    echo "                  - from 2 to 20 lower case alphanumeric characters"
    echo "                  - first character must be letter"
    echo "                  (default = 'cc')"
    echo "              [-C <root currency>]"
    echo "                  root currency"
    echo "                  - from 1 to 5 lower case alphanumeric characters"
    echo "                  - first character must be letter"
    echo "                  (default = 'cc')"
    echo "              [-h] show help" 
    echo
}

URL_RE='^([a-zA-Z0-9](([a-zA-Z0-9-]){0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$'
EMAIL_RE='^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$'
NAMESPACE_RE='^[a-z]{1,20}$'
CURRENCY_RE='^[a-z]{1,5}$'

ROOT_NAMESPACE='cc'
ROOT_CURRENCY='cc'

while [ -n "$(echo $1 | grep '^-[uaNCh]$')" ]; do
    case $1 in
        -u ) if [[ $2 =~ $URL_RE ]]; then
                 API_URL=$2
                 shift
             else
                 echo "API URL format is invalid: $2"
                 usage
                 exit 1
             fi
             ;;
        -a ) if [[ $2 =~ $EMAIL_RE ]]; then
                 ADMIN_EMAIL=$2
                 shift
             else
                 echo "Admin email address format is invalid: $2"
                 usage
                 exit 1
             fi
             ;;
        -N ) if [[ $2 =~ $NAMESPACE_RE ]]; then
                 ROOT_NAMESPACE=$2
                 shift
             else
                 echo "Root namespace is invalid: $2"
                 usage
                 exit 1
             fi
             ;;
        -C ) if [[ $2 =~ $CURRENCY_RE ]]; then
                 ROOT_CURRENCY=$2
                 shift
             else
                 echo "Root currency is invalid: $2"
                 usage
                 exit 1
             fi
             ;;
        -h ) usage 
             exit 1
             ;;
        * )  echo "Unrecognized option"
	     usage 
             exit 1
    esac
    shift
done

if [ -z $API_URL ]; then
    echo "You must specify a valid URL for the API"
    usage
    exit 1
fi

if [ -z $ADMIN_EMAIL ]; then 
    echo "You must specify a valid email address for the administrator"
    usage
    exit 1
fi


sed -i "s/cloud\.openmoney\.cc/$API_URL/g" api/swagger/swagger.yaml
sed -i "s/cloud\.openmoney\.cc/$API_URL/g" api/swagger/swagger.json
sed -i "s/cloud\.openmoney\.cc/$API_URL/g" api/oauth2server/db/clients.js

cp includes/om-api.config.example om-api.config
sed -i "s/admin@example\.net/$ADMIN_EMAIL/" om-api.config
sed -i "s/ROOT_SPACE=cc/ROOT_SPACE=$ROOT_NAMESPACE/" om-api.config
sed -i "s/ROOT_CURRENCY=cc/ROOT_CURRENCY=$ROOT_CURRENCY/" om-api.config

