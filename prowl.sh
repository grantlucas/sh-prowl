#!/bin/sh

#set the API key from the environment variable
if [ ! -z $PROWL_APIKEY ]; then
  API_KEY=$PROWL_APIKEY
else
  echo "Prowl API Key not set as an environment variable. Add \"export PROWL_APIKEY={key}\" to your .bash_profile or .profile"
  exit 1
fi

# process options
while getopts s:a: o
do  case "$o" in
  s) SUBJECT=$OPTARG;;
  a) APPLICATION=$OPTARG;;
  esac
done
# shift the option values out
shift $(($OPTIND - 1))

#TODO: Throw errors for missing options as they are all required

#use everything but the options as the message to send
MESSAGE=$*

call=`curl -s -d "apikey=$API_KEY&application=\"$APPLICATION\"&event=\"$SUBJECT\"&description=\"$MESSAGE\"" https://api.prowlapp.com/publicapi/add`

echo $call

#TODO: Add an option to supress the use of xmllint incase it's not on a system. people can turn it off
#TODO: parse the result with xmllint to analyze the response
