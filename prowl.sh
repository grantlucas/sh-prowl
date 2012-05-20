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
raw=0

#TODO: Add support for priority
# process options
while getopts s:a:vr o
do  case "$o" in
  s) SUBJECT=$OPTARG;;
  a) APPLICATION=$OPTARG;;
  v) verbose=1;;
  r) raw=1;;
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
call=`curl -s -d "apikey=$API_KEY&application=$APPLICATION&event=$SUBJECT&description=$MESSAGE" https://api.prowlapp.com/publicapi/add`

# Display raw output for debugging
if [ $raw == "1" ]; then
  echo $call
fi

# If verbose is set to true, then use xpath to process the response
if [ $verbose == "1" ]; then
  #Only process if xpath is installed
  xpath=`command -v xpath`
  if [ ! -z $xpath ]; then
    #since this script is only for sending a message, we can assume the finding of a success code means it worke
    success=`echo $call | xpath //success/@code=200 2>/dev/null`
    if [ $success == "1" ]; then
      echo "Message sent successfully"
      exit 0
    else
      #FIXME: Display the error code and response text
      echo "Message sending failed"
      exit 1
    fi
  else
    echo "Verbose output aborted. Xpath is required to process response."
  fi
fi
