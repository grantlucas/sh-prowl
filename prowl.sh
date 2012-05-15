#!/bin/sh

#set the API key from the environment variable
if [ ! -z $PROWL_APIKEY ]; then
  API_KEY=$PROWL_APIKEY
else
  echo "Prowl API Key not set as an environment variable. Add \"export PROWL_APIKEY={key}\" to your .bash_profile or .profile"
  exit 1
fi

#Set defaults
verbose=0

#TODO: Add support for priority
# process options
while getopts s:a:v o
do  case "$o" in
  s) SUBJECT=$OPTARG;;
  a) APPLICATION=$OPTARG;;
  v) verbose=1;;
  esac
done
# shift the option values out
shift $(($OPTIND - 1))

#use everything but the options as the message to send
MESSAGE=$*

#Ensure subject is supplied as it's required
if [ -z "$SUBJECT" ]; then
  echo "Subject is required. Use \"-s\" to set it."
  #TODO: Create function for showing usage text
  exit 1
fi

#Ensure app is supplied as it's required
if [ -z "$APPLICATION" ]; then
  echo "Application is required. Use \"-a\" to set it."
  #TODO: Create function for showing usage text
  exit 1
fi

#Ensure that a message was provided after argument parsing
if [ -z "$MESSAGE" ]; then
  echo "No message was provided to send."
  exit 1
fi

# Send off the message to prowl
call=`curl -s -d "apikey=$API_KEY&application=\"$APPLICATION\"&event=\"$SUBJECT\"&description=\"$MESSAGE\"" https://api.prowlapp.com/publicapi/add`

echo $call

# If verbose is set to true, then use XMLlint to process the response
if [ $verbose == "1" ]; then
  #TODO: parse the result with xmllint to analyze the response
  #TODO: only process if xmllint is installed
  echo "process XML response"
fi
