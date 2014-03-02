#!/usr/bin/env bash

# Requirements:
# 	curl

echo  "Please enter an email address to check against https://haveibeenpwned.com: "
read choice

response=$(curl --write-out %{http_code} --silent --output /dev/null "https://haveibeenpwned.com/api/breachedaccount/$choice")

if [ "$response" = "404" ];then
    echo "NOT FOUND - Email address is not found within database."

elif [ "$response" = "400" ];then
    echo "ERROR - An error occurred, please try your search again." 
   
else
    temp=$(curl --silent --request GET "https://haveibeenpwned.com/api/breachedaccount/$choice")
    echo  "Email address ($choice) was found as a result of the "$temp" breach."
    echo  "Do you require further details? [Y/N]"
    read ans
    if [ "$ans" = "y" ] || [ "$ans" = "Y" ] ; then
		curl --silent --request GET "https://haveibeenpwned.com/api/v2/breachedaccount/$choice"|python -mjson.tool > $choice.txt
		cat $choice.txt|sed -e 's!http\(s\)\{0,1\}://[^[:space:]]*!!g' -e 's/[@#\$%^&*()=039"]//g' -e 's/<\/td>//g' -e 's/<em>//g' -e 's/<\/em>//g' -e 's/<a//g'  -e 's/<\/a>//g'  >  Breach_$choice.txt
		cat Breach_$choice.txt
		rm $choice.txt

		echo "Do you wish to reatain a log file of this search? [Y/N]"
		read retain
		if [ "retain" = "y" ] || [ "retain" = "Y" ] ; then
			echo "Output saved it into Breach_$choice.txt file"
		else
			rm Breach_$choice.txt
    	fi
		exit 1
	fi

    if [ "$ans" = "n" ] || [ "$ans" = "N" ] ;then 	
		exit 1
    fi
	    
fi