#!/bin/sh
if [ ${CONFIGURATION} == "Release" ]; then
	buildNumber=`/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "$INFOPLIST_FILE"`
	buildNumber=$(($buildNumber + 1))
	gitBranch=`git rev-parse --abbrev-ref HEAD`
	gitCommit=`git rev-parse --short HEAD`
	gitTag=`git tag --points-at HEAD`
	/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $buildNumber" "$INFOPLIST_FILE"
	/usr/libexec/PlistBuddy -c "Set :X-SCM-Branch $gitBranch" "$INFOPLIST_FILE"
	/usr/libexec/PlistBuddy -c "Set :X-SCM-Commit $gitCommit" "$INFOPLIST_FILE"
	/usr/libexec/PlistBuddy -c "Set :X-SCM-Tag $gitTag" "$INFOPLIST_FILE"
fi
