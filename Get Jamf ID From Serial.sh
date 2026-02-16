#!/usr/bin/env bash

# set apiusername and apipassword, otherwise great sadness

# variables
apiURL=$( /usr/bin/defaults read "/Library/Preferences/com.jamfsoftware.jamf.plist" jss_url )
apiURL=${apiURL%%/} # remove trailing slash

serial=$(ioreg -c IOPlatformExpertDevice -d 2 | awk -F\" '/IOPlatformSerialNumber/{print $(NF-1)}')

# the right to bear tokens

# Get username and password encoded in base64 format and stored as a variable in a script:
encodedCredentials=$(printf apiusername:apipassword | /usr/bin/iconv -t ISO-8859-1 | /usr/bin/base64 -i -)
# a Jamf Pro user can be assigned custom privileges to not be able to view Scripts, so in theory hardcoding here is safer
# than passing a parameter - you want your jr techs to be able to view a Policy & flush logs as part of routine t/s

# Use encoded username and password to request a token with an API call and store the output as a variable in a script:
authToken=$(/usr/bin/curl "$apiURL"/api/v1/auth/token --silent --request POST --header "Authorization: Basic ${encodedCredentials}")


# Read the output, extract the token information and store the token information as a variable in a script:
api_token=$(/usr/bin/plutil -extract token raw -o - - <<< "$authToken")


# Verify that the token is valid and unexpired by making a separate API call, checking the HTTP status code and storing status code information as a variable in a script:
api_authentication_check=$(/usr/bin/curl --write-out %{http_code} --silent --output /dev/null "$apiURL"/api/v1/auth --request GET --header "Authorization: Bearer ${api_token}")


# Assuming token is verified to be valid, use the token information to make an API call:
id=$(/usr/bin/curl --silent -k -H "Accept: application/xml" --header "Authorization: Bearer ${api_token}" "$apiURL"/JSSResource/computers/serialnumber/"$serial" | grep -o '<computer><general><id>[^<]*' | sed 's/<computer><general><id>//' )

echo $id

exit 0
