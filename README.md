iOS Build Scripts for Xcode Bots
=================

Build scripts that can be used to update build #, upload binary to HockeyApp, and post notifications into HipChat from an Xcode Bot.

How to use these scripts
========================

First, if you are not familiar with creating Xcode Bots, please do some research on this topic first as these scripts are only designed to be used with Xcode Bots.

The first step is to create your Bot. After you've done this follow the instructions below to setup both scipts.

Setting up update_version.sh
----------------------------
1. On your Xcode Server machine, cd into the `/Library/Developer/XcodeServer/` director and create a new folder called `Config`.
2. Inside of the newly created `Config` folder create a new folder for each of the build configurations that you'll be using with Xcode Bots. For example, if you have an Ad Hoc and/or an Enterprise configuration in your project that you'll be using for builds make sure you create a folder with this configurations name.<sup>A</sup>
3. For each configuration directory you created, within the directory, create a new plist file that that is named just like your projects Info.plist. For example, if the name of your project is MyAwesomeApp then your Info.list file would be named `MyAwesomeApp-Info.plist`.<sup>B</sup> You'll need to add only one `dict` within the Info.plist that will have one KVP. The key will be `CFBundleVersion` and the value will be `0`.<sup>C</sup>
4. Now that you've got all of the proper directories and plist files in place, you are ready to add the `update_version.sh` script to your project. To do this, open your project and create a new `Target` > `External Build System`. You can name this Target what ever you want, I typically use `Update Build Version`. After the new Target has been created, select the `Info` tab and input the following values. Please note, this assumes you've placed the `update_version.sh` script in the root directory of you project. If not, you'll need to use to actual path in which you placed the script in your project.
    - Build Tool: /bin/sh
    - Arguments: $PROJECT_DIR/update_version.sh
    - Directory: $PROJECT_DIR/
5. From the scheme selection drop down, select the scheme that you'll be building in your Xcode Bot, then choose `Edit Scheme...`. Select `Build` and click the + to add a new Target. Choose the Target you created in step 4. Make sure you move it to the very top of the list of Targets and unselect everything except `Archive`.<sup>D</sup>
6. You have finished setting up the `update_version.sh` script.

<sup>A</sup>

![Configs](http://note.io/1J8HOuu)

<sup>B</sup>

![Configs-Ad-Hoc](http://note.io/1Gv3Wx4)

<sup>C</sup>

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleVersion</key>
	<string>0</string>
</dict>
</plist>
```

<sup>D</sup>

![Configs-Ad-Hoc](http://note.io/1Gv6A63)

Setting up upload.sh
====================

1. In the last screen of the new Xcode Bot creation/update menu you'll have the oppertunity to add Before and After Integration Run Scripts. The first step will be to create a `Before Integration` Run Script that will be used to configure git so that it can send tags to your github repository during each build.
2. The first thing you'll need to do is get a `Peronal Access Token` so that the Bot can push tags back to your repo. To do this open https://github.com/settings/applications and click on `Generate new token`. Unselect everything except either `repo` if your repository is private or `public_repo` if your repository is public. Copy your new personal access token and enter it in the git configuration code that is reference in the next step.
3. From the last screen of the Xcode Bot creation/update menu click the `+ Add Trigger` button in the `Before Integration` section. When the new Run Script box appears, enter the lines from the example in <sup>E</sup> below and replace everything inside of a `<...>` tag with your appriopriate information.
4. Now scroll down to the `After Integration` section and click the `+ Add Trigger` and enter in the lines from example <sup>F</sup>. Make sure to update all information in these lines accordingly. Please note, this assumes you've placed the `upload.sh` script in the root directory of your project. If not, you'll need to update it accordingly.
5. As long as you've properly configured everything you should now be ready to start an integration and see that your build # has incremeneted, you got a build in TestFlight, and if have HipChat and configured the settings for HipChap received a build notificaion within the HipChat room of your choosing.

<sup>E</sup>

```
cd "$XCS_SOURCE_DIR/<YOUR-PROJECTS-ROOT-DIRECTORY-GOES-HERE>"
git config user.email "ci@buildbox.com"
git config user.name "Build Box"
git config remote.origin.url "https://<YOUR-GITHUB-PERSONAL-ACCESS-TOKEN-HERE>@github.com/<YOUR-GITHUB-ACCOUNT-NAME-HERE>/<YOUR-REPO-NAME-HERE>.git"
git config -l
```

<sup>F</sup>

```
PRODUCT_NAME="MyAwesomeApp"
SRCROOT_MAIN_DIR="my_awesome_app"
GITHUB_ACCOUNT="atljeremy"
DISTRO_LIST="<YOUR-TESTFLIGHT-DISTRIBUTION-LIST-NAME-HERE>"
HOCKEYAPP_API_TOKEN="<YOUR-HOCKEYAPP-API-TOKEN-HERE>"
SIGNING_IDENTITY="iPhone Distribution: Jeremy Fox"
PROVISIONING_PROFILE="52bf378s-ea37-738e-djs9-shdisdisciod8ju"

# Posting to HipChat is supported, if you have a HipChat room that you would like build notifications sent into, uncomment the lines below and enter in your appropriate info
# HIPCHAT_ROOM_NAME="MyAwesomeApp Room"
# HIP_CHAT_AUTH_TOKEN="hsishid8ew8yei8yifyri8ysyi"

source "$XCS_SOURCE_DIR/$SRCROOT_MAIN_DIR/upload.sh"
```
