#!/bin/bash
#Leonidas Poursanidis 2874

#TODO:
#DONE1-Read first https link in all txt files under .tar.gz and ignore comments or anything further
#DONE2-Create local assignments folder and clone each repo found in there 
#reponame: Cloning OK or Cloning FAILED
#3-Count number of directories txt and other files and print them for each repo
#4-For each repo check file structure to be dataA.xt & more__dataB.txt&dataC.txt 
#and print OK otherwise print NOT OK

#File where the tar.gz file is extracted
EXTR_DIR=$(mktemp --tmpdir=./ -d repofilesXXX)
#File where the links are stored
REPO_LINKS=$(mktemp --tmpdir=./ repolinksXXX.txt)
#Cleans up the previously created temporary files
clean_up(){
	rm -rf "./$EXTR_DIR"
	rm -rf "./$REPO_LINKS"
}

#Extracts the tar and stores the links found
get_repos_from_dir(){
tar -C $EXTR_DIR -xf "$1" #Do the extraction on the temporary directory
for text in $(find $EXTR_DIR -name '*.txt'); do #Read all the txt files in there
	while read -r repo; do
		if [[ $repo =~ ^"https" ]]; then 
			echo $repo >> $REPO_LINKS #Store the highest up line(that isn't a comment) for every file
			break
		fi
	done < "$text"
done
}

#Clones repositories into an assignments folder without .git
clone_repos(){
	#Make a clean assignments folder to clone in
	rm -rf ./assignments
	mkdir assignments
	#Try to clone each link and print the results
	while read -r repolinks; do
		local LOCALREPONAME="./assignments/$(basename "$repolinks" .git)"
		git clone -q "$repolinks" "$LOCALREPONAME" &> /dev/null
		if [ $? -eq 0 ]; then #Show the Cloning result
			echo "$repolinks: Cloning OK"
		else
			echo "$repolinks: Cloning FAILED"
		fi
		#Clearing the .git folder that github adds
		rm -rf "$LOCALREPONAME/.git"
	done < "$REPO_LINKS"
}

report_file_structure(){
	if [ ! -n "$(find "./assignments" -maxdepth 0 -type d -empty 2>/dev/null)" ]; then
		for REPO in ./assignments/*; do
			local LFLAG=0 #Flag to check all 4 needed prerequisites for the structure of one
			local DIRNUM=0
			local TXTNUM=0
			local OTHERNUM=0
			for FILE in $(find $REPO -mindepth 1); do
				#Counting the files
				if [[ -d "$FILE" ]]; then
					DIRNUM=$((DIRNUM+1))
				elif [[ $FILE == *.txt ]]; then
					TXTNUM=$((TXTNUM+1))
				else
					OTHERNUM=$((OTHERNUM+1))
				fi
			done
			#Checking structure, by incrementing the flag each time a prerequisite is completed
			if [ -e "$REPO/dataA.txt" ]; then
				LFLAG=$((LFLAG+1))
			fi
			if [ -d "$REPO/more" ]; then
				if [ -e "$REPO/more/dataB.txt" ]; then
					LFLAG=$((LFLAG+1))
				fi
				if [ -e "$REPO/more/dataC.txt" ]; then
					LFLAG=$((LFLAG+1))
				fi
			fi
			echo "$(basename "$REPO"):"
			echo "Number of directories: $DIRNUM"
			echo "Number of txt files: $TXTNUM"
			echo "Number of other files: $OTHERNUM"
			if [[ $LFLAG = 3 && $DIRNUM = 1 && $TXTNUM = 3 && $OTHERNUM = 0 ]]; then
				echo "Directory structure is OK"
			else
				echo "Directory structure is NOT OK"
			fi
		done
	fi
}

#Get the links for each repository to be downloaded
get_repos_from_dir $1
#Download all the repositories cleanly
clone_repos
#Cleanup the temporary folders
clean_up
#Report the file count for each repo and it's structural integrity
report_file_structure


