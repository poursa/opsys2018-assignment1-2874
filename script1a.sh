#!/bin/bash
# Leonidas Poursanidis 2874


#Getting the md5sum of a string
getmd5(){
	echo -n $1 | md5sum | sed 's/ -$//'

}

while read link; do #we do the checking for every link
	if [[ !($link =~ ^"#") ]]; then #Ignoring all comments in the read file
		#looking to see if the link is already recorded
		#     \/
		if grep -qs "$link" hashes.txt; then #the link already existed before so we check the difference
			echo "Found" #TODO: Check with previous
		else #the link is new so we output its name along INIT
			echo "$link INIT"
			#We record the link's hash or failure
			REQUEST=$(curl -s $link 2>&1)
			if [ $? -eq 0 ]; then #if the page is downloadable
				#download the page, get its hash and throw it in a file
				#the double inversion is there to wait for the curl to finish
				echo "$link : $(echo $REQUEST | tac | tac | md5sum | sed 's/ -$//')" >> hashes.txt
				#								/\
				#    								||
				#		Deleting the trailing - and space to get a bare md5sum
			else #if the page fails
				echo "$link FAILED"
				echo "$link : FAILED" >> hashes.txt
			fi
		fi
	fi
done <links.txt
