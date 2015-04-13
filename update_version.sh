#!/bin/bash
#
# (Above line comes out when placing in Xcode scheme)
#

############################################################################
# Configurable Options
############################################################################

############################################################################
# Used to tell the build system where to find the local tracking copying of
# the projects info.plist file which is used to keep track of the build #.
#
# Set this ENV variable before calling this script or default value will be used.
TRACKING_PLIST_PATH=${TRACKING_PLIST_PATH:="/Library/Developer/XcodeServer/Config/$CONFIGURATION"}

############################################################################
# Used to tell the build system where to find the projects info.plist file
#
# Set this ENV variable before calling this script or default value will be used.
PROJ_PLIST=${PROJ_PLIST:="${XCS_SOURCE_DIR}/${PROJECT_NAME}/${PROJECT_NAME}-Info.plist"}

############################################################################
# Used to tell the build system if it should upload the new version to source sontrol
#
# Set this ENV variable before calling this script or default value will be used.
COMMIT_VERSION=${COMMIT_VERSION:=0}

############################################################################
# DO NOT CHANGE ANYTHING BELOW THIS LINE
############################################################################

echo "Bumping build number..."
echo "PROJECT PLIST FILE: $PROJ_PLIST"
PLIST="$TRACKING_PLIST_PATH/${PROJECT_NAME}-Info.plist"
echo "PLIST FILE: $PLIST"

# increment the build number
BUNDLE_VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "${PLIST}")
if [[ "${BUNDLE_VERSION}" == "" ]]; then
  echo "No build number in $plist"
  exit 2
fi

IFS='.' read -a BUNDLE_PARTS <<< "$BUNDLE_VERSION"
LAST_PART_INDEX=$(expr ${#BUNDLE_PARTS[@]} - 1)
LAST_PART=$(expr ${BUNDLE_PARTS[$LAST_PART_INDEX]} + 1)
BUNDLE_PARTS[$LAST_PART_INDEX]=$LAST_PART

function join { local IFS="$1"; shift; echo "$*"; }
NEW_BUNDLE_VERSION=$(join . ${BUNDLE_PARTS[@]})

/usr/libexec/Plistbuddy -c "Set CFBundleVersion $NEW_BUNDLE_VERSION" "${PLIST}"
/usr/libexec/Plistbuddy -c "Set CFBundleVersion $NEW_BUNDLE_VERSION" "${PROJ_PLIST}"

if [ $COMMIT_VERSION -eq 1 ]; then
  CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
  echo "Committing the build number to branch: $CURRENT_BRANCH"
  cd ${PROJECT_DIR}; git add $PLIST
  cd ${PROJECT_DIR}; git commit -m "Bumped the build number to $NEW_BUNDLE_VERSION"
  cd ${PROJECT_DIR}; git push -u origin $CURRENT_BRANCH
  echo "Build number committed."
else
  echo "Not committing build number."
  echo "To commit new build numbers set COMMIT_VERSION=1."
fi

echo "Bumped build number to $NEW_BUNDLE_VERSION"
