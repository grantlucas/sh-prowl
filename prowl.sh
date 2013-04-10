#!/bin/bash

usage()
{
  echo "
Usage: prowl.sh (-vr) [-s Subject] [-a Application] (-p Priority {-2 => 2})  message
Try 'prowl.sh -h' for more information."
  exit 1
}

help()
{
  echo "
Usage: prowl.sh (-vr) [-s Subject] [-a Application] (-p Priority {-2 => 2})  message

Options:
  -s SUBJECT (Required)
    The subject line of the message that is being sent
  -a APPLICATION (Required)
    The application the message is coming from
  -p {-2 => 2}
    The priority of the message.
  -v
    Displays a success or failure message after receiving response using XPath if XPath is available
  -r
    Displays the raw XML output response from Prowl
  -h
    Shows this help text"
  exit 1
}

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
PRIORITY=0

# process options
while getopts s:a:p:vrh o
do  case "$o" in
  s) SUBJECT=$OPTARG;;
  a) APPLICATION=$OPTARG;;
  p) PRIORITY=$OPTARG;;
  v) verbose=1;;
  r) raw=1;;
  h) help;;
[?]) usage;;
  esac
done
# shift the option values out
shift $(($OPTIND - 1))

#use everything but the options as the message to send
MESSAGE=$*

#Ensure subject is supplied as it's required
if [ -z "$SUBJECT" ]; then
  echo "Subject is required. Use \"-s\" to set it."
  usage
  exit 1
fi

#Ensure app is supplied as it's required
if [ -z "$APPLICATION" ]; then
  echo "Application is required. Use \"-a\" to set it."
  usage
  exit 1
fi

if [ "$PRIORITY" -lt "-2" ]; then
  echo "Priority cannoy be lower than -2 (Very Low)"
  usage
  exit 1
fi

if [ "$PRIORITY" -gt "2" ]; then
  echo "Priority cannoy be higher than 2 (Emergency)"
  usage
  exit 1
fi

#Ensure that a message was provided after argument parsing
if [ -z "$MESSAGE" ]; then
  echo "No message was provided to send."
  usage
  exit 1
fi

# Send off the message to prowl
call=`curl -s -d "apikey=$API_KEY&priority=$PRIORITY&application=$APPLICATION&event=$SUBJECT&description=$MESSAGE" https://api.prowlapp.com/publicapi/add`

# Display raw output for debugging
if [ "$raw" == "1" ]; then
  echo "$call"
fi

# If verbose is set to true, then use xpath to process the response
if [ "$verbose" == "1" ]; then

  sed_avail=`command -v sed`
  if [ ! -z "$sed_avail" ]; then
    if [[ "$call" =~ "success" ]]; then
      echo "Message sent successfully"
      exit 0
    else
      # Get the error message and code
      errmsg=`echo "$call" | sed -n '/error/ s/.*>\(.*\)\<.*/\1/p'`
      errcode=`echo "$call" | sed -n '/error/ s/.*code=\"\(.*\)".*/\1/p'`
      echo "Message sending failed: ($errcode) $errmsg"
      exit 1
    fi
  else
    echo "Verbose output aborted. Sed is required to process response."
  fi
fi
