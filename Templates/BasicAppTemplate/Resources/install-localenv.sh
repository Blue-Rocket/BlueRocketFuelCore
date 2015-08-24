#!/bin/bash
filePath="${PROJECT_DIR}/LocalEnvironment.plist"
buildDir="${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
if [ ${CONFIGURATION} == "Debug" ]; then
    if [ -e "$filePath" ]; then
        cp "$filePath" "${buildDir}/"
        echo "$filePath copied to ${buildDir}"
    else
        echo "$filePath not found."
    fi
else
    echo "$filePath not copied for ${CONFIGURATION} builds."
fi

# Check for environment stuff to copy, presumably set by a scheme pre-build script
targetEnv=`/usr/libexec/PlistBuddy -c "Print :X-App-Target" "${buildDir}/Environment.plist"`
if [ -n "${targetEnv}" ]; then
	echo "Target environment: ${targetEnv}"
	${PROJECT_DIR}/Resources/merge-env-plists.sh "${targetEnv}"
fi
