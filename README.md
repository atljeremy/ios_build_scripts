iOS Build Scripts for Xcode Bots
=================

Build scripts that can be used to update build #, upload binary to TestFlight, and post notifications into HipChat from an Xcode Bot.

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

###Setting up upload.sh


<!--<sup>A</sup>-->
<!--![Config](https://dl-web.dropbox.com/get/iOS%20Build%20Script%20Repo%20Images/config-ad-hoc.png?_subject_uid=55388810&w=AAAHLK2sgVEV7RoWz5jsFngibKTnGtvgrLtacJyzE9m-3Q)-->
