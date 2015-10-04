#!/bin/bash

function mergePlists {
	if [ -e "$1" -a -e "$2" ]; then
		echo "Merge $1 into $2"
		for key in `/usr/libexec/PlistBuddy -c Print "$1" |sed -n '/=/s/^    \([a-zA-Z_\-]*\) =.*/\1/p'`; do
			echo "Delete key $key..."
			/usr/libexec/PlistBuddy -c "Delete :$key" "$2"
		done
		/usr/libexec/PlistBuddy -c "Merge $1" "$2"
	else
		echo "Merge files missing: '$1' or '$2'"
	fi
}

echo "Hello from $0 : $1"
echo "CONFIGURATION = ${CONFIGURATION}"
echo "INFOPLIST_FILE = ${INFOPLIST_FILE}"

destEnv="$1"
infoPlist="${PROJECT_DIR}/${INFOPLIST_FILE%.plist}"
envPlist="${PROJECT_DIR}/Environment"
buildDir="${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"

echo "Dest: $destEnv"
echo "Info: $infoPlist"
echo "Env:  $envPlist"

mergePlists "${infoPlist}-${destEnv}.plist" "${buildDir}/Info.plist"
mergePlists "${envPlist}-${destEnv}.plist" "${buildDir}/Environment.plist"
