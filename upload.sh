#!/bin/bash
#
# (Above line comes out when placing in Xcode scheme)
#

############################################################################
# Example of usage in Xcode Bot
############################################################################
# This script was designed to be run from a post integration step of an Xcode
# Bot. Here is an example of how to do this.
#
# PRODUCT_NAME="MyAwesomeApp"
# SRCROOT_MAIN_DIR="my_awesome_app"
# HIPCHAT_ROOM_NAME="MyAwesomeApp Room"
# HIP_CHAT_AUTH_TOKEN="hsishid8ew8yei8yifyri8ysyi"
# GITHUB_ACCOUNT="atljeremy"
# DISTRO_LIST="MyAwesomeApp TestFlight Distro List Name"
# TESTFLIGHT_API_TOKEN="kahsdiuHISUhdsi8sd9oshjh_hskdihsaskdiao98asydhaisuhISL"
# TESTFLIGHT_TEAM_TOKEN="hiuasdhfiouyhuyefijkuehwfkiuyghaksdyjfgkuyds__hsidkuh&UUHIuhdsk"
# SIGNING_IDENTITY="iPhone Distribution: Jeremy Fox"
# PROVISIONING_PROFILE="52bf378s-ea37-738e-djs9-shdisdisciod8ju"
#
# source "$XCS_SOURCE_DIR/$SRCROOT_MAIN_DIR/upload.sh"

############################################################################
# Configurable Options
############################################################################

############################################################################
# Used to tell the build system if a build should fail if the upload process fails
#
# Set this ENV variable before calling this script or the default value will be used.
REQUIRE_UPLOAD_SUCCESS=${REQUIRE_UPLOAD_SUCCESS:=1}

############################################################################
# Used to tell the build system which HipChat Room should receive build notifications
#
# Set this ENV variable before calling this script or the default value will be used.
HIPCHAT_ROOM_NAME=${HIPCHAT_ROOM_NAME:="NOT_DEFINED"}

############################################################################
# Used to tell this script to notify the HipChat room specified in
# HIPCHAT_ROOM_NAME variable. If NOTIFY_HIPCHAT_ROOM is set to 1 (true) and 
# HIPCHAT_ROOM_NAME is not set, the build will fail.
#
# Set this ENV variable before calling this script or the default value will be used.
NOTIFY_HIPCHAT_ROOM=${NOTIFY_HIPCHAT_ROOM:=1}

############################################################################
# Used to tell the build system if members of the HIPCHAT_ROOM_NAME should receive
# a notification when the build system posts a build notificaiton
#
# Set this ENV variable before calling this script or the default value will be used.
POST_NOTIFY=${POST_NOTIFY:=true}

############################################################################
# Used to tell the build system what HipChat Auth Token should be used for requests
# to the HipChat API
#
# Set this ENV variable before calling this script or the default value will be used.
HIP_CHAT_AUTH_TOKEN=${HIP_CHAT_AUTH_TOKEN:="NOT_DEFINED"}

############################################################################
# Used to specify the source control main directory
#
# Set this ENV variable before calling this script.
SRCROOT_MAIN_DIR=${SRCROOT_MAIN_DIR:="$PRODUCT_NAME"}

############################################################################
# Used to specify the Github account in which tags should be sent
#
# Set this ENV variable before calling this script or the default value will be used.
GITHUB_ACCOUNT=${GITHUB_ACCOUNT:="NOT_DEFINED"}

############################################################################
# Set the Enterprise App Store Project ID that these builds should be uploaded to
# This defaults to project ID 24 if not set, which is the "AG Testing" project.
#
# Set this ENV variable before calling this script or the default value will be used.
DISTRO_LIST=${DISTRO_LIST:="All"}

############################################################################
# TestFlight api token to be used for upload request
#
# Set this ENV variable before calling this script or the default value will be used.
TESTFLIGHT_API_TOKEN=${TESTFLIGHT_API_TOKEN:="NOT_DEFINED"}

############################################################################
# TestFlight team token to be used for upload request
#
# Set this ENV variable before calling this script or the default value will be used.
TESTFLIGHT_TEAM_TOKEN=${TESTFLIGHT_TEAM_TOKEN:="NOT_DEFINED"}

############################################################################
# Signing Certificate used to sign the IPA
#
# Set this ENV variable before calling this script or the default value will be used.
SIGNING_IDENTITY=${SIGNING_IDENTITY:="NOT_DEFINED"}

############################################################################
# Provisioning Profile used to provision the IPA
#
# Set this ENV variable before calling this script or the default value will be used.
PROVISIONING_PROFILE=${PROVISIONING_PROFILE:="NOT_DEFINED"}


############################################################################
# DO NOT CHANGE ANYTHING BELOW THIS LINE
############################################################################

XCODE_SERVER_DIR="/Library/Developer/XcodeServer"
URL="http://testflightapp.com/api/builds.json"
PROVISIONING_PROFILE="$XCODE_SERVER_DIR/ProvisioningProfiles/${PROVISIONING_PROFILE}.mobileprovision"
SRCROOT=${SRCROOT:="$XCS_SOURCE_DIR/$SRCROOT_MAIN_DIR/"}
echo "SRCROOT: $SRCROOT"
NOTES=`cd ${SRCROOT}; git log --pretty=format:"%h - %an, %ar : %s" -n 1`
SHA=`cd ${SRCROOT}; git rev-parse HEAD`
DSYM="/tmp/Archive.xcarchive/dSYMs/${PRODUCT_NAME}.app.dSYM"
DSYM_ZIP="${DSYM}.zip"
IPA="/tmp/${PRODUCT_NAME}.ipa"
APP="/tmp/Archive.xcarchive/Products/Applications/${PRODUCT_NAME}.app"
 
# Clear out any old copies of the Archive
echo "---------------------------------------------------"
echo "Removing old files from /tmp...";
/bin/rm -rf /tmp/Archive.xcarchive*
echo "Done removing old files from /tmp";
echo "---------------------------------------------------"
 
# Copy over the latest build the bot just created
echo "---------------------------------------------------"
echo "Copying latest app to /tmp/...";
/bin/cp -Rp "$XCS_ARCHIVE" "/tmp/"
echo "Done copying latest app to /tmp/";
echo "---------------------------------------------------"

# Create the .ipa to be uploaded
echo "---------------------------------------------------"
echo "Creating .ipa for ${PRODUCT_NAME}"
/usr/bin/xcrun -sdk iphoneos PackageApplication -v "${APP}" -o "${IPA}" --embed "${PROVISIONING_PROFILE}"
echo "Done with IPA creation."
echo "---------------------------------------------------"

# Create the zipped .dSYM
echo "---------------------------------------------------"
echo "Zipping .dSYM for ${PRODUCT_NAME}"
/bin/rm "${DSYM}.zip"
/usr/bin/zip -r "${DSYM}.zip" "${DSYM}"
echo "Done creating .dSYM for ${PRODUCT_NAME}"
echo "---------------------------------------------------"

# Upload the build
echo "---------------------------------------------------"
echo "Beginning upload with the following params... "
echo "file: ${IPA}"
echo "dsym: ${DSYM_ZIP}"
echo "api_token: ${TESTFLIGHT_API_TOKEN}"
echo "team_token: ${TESTFLIGHT_TEAM_TOKEN}"
echo "distribution_lists: ${DISTRO_LIST}"
echo "notes: ${NOTES}"

# HTTP_STATUS=$(curl "${URL}" --write-out %{http_code} --silent --output /dev/null \
#   -F file=@$IPA \
#   -F dsym=@$DSYM_ZIP \
#   -F api_token="${TESTFLIGHT_API_TOKEN}" \
#   -F team_token="${TESTFLIGHT_TEAM_TOKEN}" \
#   -F distribution_lists="${DISTRO_LIST}" \
#   -F notes="${NOTES}" \
#   -F notify=True)

TESTFLIGHT_RESPONSE=$(curl "${URL}" \
  -F file=@$IPA \
  -F dsym=@$DSYM_ZIP \
  -F api_token="${TESTFLIGHT_API_TOKEN}" \
  -F team_token="${TESTFLIGHT_TEAM_TOKEN}" \
  -F distribution_lists="${DISTRO_LIST}" \
  -F notes="${NOTES}" \
  -F notify=True)

echo Upload API HTTP Response: ${TESTFLIGHT_RESPONSE}

if [ ! ${TESTFLIGHT_RESPONSE} ]; then
  if [ $REQUIRE_UPLOAD_SUCCESS -eq 1 ]; then
  	echo "err: app version not succesfully uploaded."
  	echo "To ignore this condition and build succesfully, add:"
  	echo "REQUIRE_UPLOAD_SUCCESS=0"
  	echo "to the Run Script Build Phase invoking this script."
    exit 1
  else
  	echo "err: app version not succesfully uploaded"
  	echo "ignoring due to REQUIRE_UPLOAD_SUCCESS=0"
  fi
else
  
  VERSION_NUMBER=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "${APP}/Info.plist")
  BUILD_NUMBER=$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "${APP}/Info.plist")
  BOT_NAME=$(echo $XCS_BOT_NAME | tr -d [[:space:]])
  TAG_NAME="${BOT_NAME}-${VERSION_NUMBER}-${BUILD_NUMBER}"
  
  echo "Tagging release as '${TAG_NAME}'"
  echo `cd ${SRCROOT}; git tag -a ${TAG_NAME} -m "${TAG_NAME}"`
  echo `cd ${SRCROOT}; git push -u --tags`
  
  INSTALL_URL=$(echo $TESTFLIGHT_RESPONSE | python -c 'import json,sys;obj=json.load(sys.stdin);print obj["install_url"]')
  GITHUB_TAG_URL="https://github.com/$GITHUB_ACCOUNT/$SRCROOT_MAIN_DIR/releases/tag/$TAG_NAME"
  POST_COLOR=${POST_COLOR:=green}
  POST_MESSAGE="<b>$XCS_BOT_NAME Bot:</b> $PRODUCT_NAME $VERSION_NUMBER ($BUILD_NUMBER) is now available! <img src='http://cdn.meme.am/images/50x50/1152667.jpg'> <br/><b>GitHub Tag:</b> <a href='$GITHUB_TAG_URL'>$GITHUB_TAG_URL</a> <br/><b>TestFlight Install URL:</b> <a href='$INSTALL_URL'>$INSTALL_URL</a> <br/><b>Build Notes:</b> ${NOTES}"

  if [ $NOTIFY_HIPCHAT_ROOM -eq 1 ]; then
    HIPCHAT_ROOM_NAME=$(perl -MURI::Escape -e 'print uri_escape shift, , q{^A-Za-z0-9\-._~/:}' -- "$HIPCHAT_ROOM_NAME")
    if [ ! ${HIPCHAT_ROOM_NAME} ]; then
      echo "NOTIFY_HIPCHAT_ROOM is set to 1 (true) but HIPCHAT_ROOM_NAME is not set. Can't notify HipChat of build without a valid HIPCHAT_ROOM_NAME."
      exit 1;
    else
      echo "Posting notification to HipChat room: $HIPCHAT_ROOM_NAME"
      echo "With message: $POST_MESSAGE"
      HTTP_STATUS=$(curl -H "Content-Type: application/json" -d '{"color":"'"$POST_COLOR"'", "message":"'"$POST_MESSAGE"'", "notify":'"$POST_NOTIFY"'}' "https://api.hipchat.com/v2/room/${HIPCHAT_ROOM_NAME}/notification?auth_token=$HIP_CHAT_AUTH_TOKEN" --write-out %{http_code} --silent --output /dev/null)
      echo "Finished notifying HipChat room with response code: $HTTP_STATUS"
    fi
  fi
fi

echo "Upload process complete"