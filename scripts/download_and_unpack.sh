#!/bin/bash

COS_APIKEY="$1"
COS_ENDPOINT="$2"
COS_BUCKET="$3"
GARASIGN_CLIENT="$4"

if [ -z "$COS_APIKEY" ]; then
  echo "COS_APIKEY is not set"
  exit 1
fi

if [ -z "$COS_ENDPOINT" ]; then
  echo "COS_ENDPOINT is not set"
  exit 1
fi

if [ -z "$COS_BUCKET" ]; then
  echo "COS_BUCKET is not set"
  exit 1
fi

if [ -z "$GARASIGN_CLIENT" ]; then
  echo "GARASIGN_CLIENT is not set"
  exit 1
fi

# Obtain the access token
token=$(curl -s -X POST https://iam.cloud.ibm.com/identity/token \
      -H "content-type: application/x-www-form-urlencoded" \
      -H "accept: application/json" \
      -d "grant_type=urn:ibm:params:oauth:grant-type:apikey&apikey=$COS_APIKEY" | jq -r .'access_token')

# Download the garasign client
curl -s -w 'RESP_CODE:%{response_code}' -X GET "$COS_ENDPOINT"/"$COS_BUCKET"/"$GARASIGN_CLIENT" \
    -H "Authorization: Bearer ${token}" \
    --output "$GARASIGN_CLIENT" | grep -o 'RESP_CODE:[1-4][0-9][0-9]'

# Debug: Print information about the downloaded file
echo "Downloaded file:"
ls -la "$GARASIGN_CLIENT"
echo "File content:"
cat "$GARASIGN_CLIENT"

# Unzip the garasign client
tar zxvf ./"$GARASIGN_CLIENT"
