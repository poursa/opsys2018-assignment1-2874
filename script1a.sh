#!/bin/bash
# Leonidas Poursanidis 2874

filename=$1
LCOUNT=0

while read -r link; do #we do the checking for every link
	LCOUNT=$((LCOUNT+1))
	echo $LCOUNT
	if [[ !($link =~ ^"#") ]]; then #Ignoring all comments in the read file
		#looking to see if the link is already recorded
		#     \/
		PREVLINKHASH=$(grep -s "$link" hashes.txt)
		if [ $? -eq 0 ]; then #the link already existed before so we check the difference
		
			#We find the link's new hash or failure
			REQUEST=$(curl -s $link 2>&1)
			if [ $? -eq 0 ]; then #if the page is downloadable
				#download the page, get its hash and assigne it to a variable
				#the double inversion is there to wait for the curl to finish
				TEMPHASHLINE="$link : $(echo $REQUEST | tac | tac | md5sum | sed 's/ -$//')"
				#									/\
				#    								||
				#		Deleting the trailing - and space to get a bare md5sum
			else #if the page fails then we store the failure
				>&2 echo "$link FAILED" #output to stderr
				TEMPHASHLINE="$link : FAILED"
			fi
			
			##We compare the previous and current link hash/fail
			if [ "$TEMPHASHLINE" = "$PREVLINKHASH" ]; then #THere is no change
				echo "same"
			else #There is a change so we update the velue of the hash of the site
				echo "$link"
				sed -i "${LCOUNT}s,.*,$TEMPHASHLINE," hashes.txt
			fi
		else #the link is new so we output its name along INIT
			echo "$link INIT"
			#We record the link's hash or failure
			REQUEST=$(curl -s $link 2>&1)
			if [ $? -eq 0 ]; then #if the page is downloadable
				#download the page, get its hash and throw it in a file
				#the double inversion is there to wait for the curl to finish
				echo "$link : $(echo $REQUEST | tac | tac | md5sum | sed 's/ -$//')" >> hashes.txt
				#									/\
				#    								||
				#		Deleting the trailing - and space to get a bare md5sum
			else #if the page fails
				>&2 echo "$link FAILED" #output to stderr
				echo "$link : FAILED" >> hashes.txt
			fi
		fi
	fi
done < "$filename"