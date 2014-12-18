iOS Build Scripts for Xcode Bots
=================

Build scripts that can be used to update build #, upload binary to TestFlight, and post notifications into HipChat from an Xcode Bot.

How to use these scripts
========================

First, if you are not familiar with creating Xcode Bots, please do some research on this topic first as these scripts are only designed to be used with Xcode Bots.

The first step is to create your Bot. After you've done this follow the instructions below to setup both scipts.

###Setting up update_version.sh

1. On your Xcode Server machine, cd into the `/Library/Developer/XcodeServer/` director and create a new folder called `Config`.
2. Inside of the newly created `Config` folder create a new folder for each of the build configurations that you'll be using with Xcode Bots. For example, if you have an Ad Hoc and/or an Enterprise configuration in your project that you'll be using for builds make sure you create a folder with this configurations name.<sup>A</sup>
3. For each configuration directory you created, within the directory, create a new plist file that that is named just like your projects Info.plist. For example, if the name of your project is MyAwesomeApp then your Info.list file would be named `MyAwesomeApp-Info.plist`.<sup>B</sup> You'll need to add only one `dict` within the Info.plist that will have one KVP. The key will be `CFBundleVersion` and the value will be `0`.<sup>C</sup>
4. 

<sup>A</sup>
![Config](https://dl-web.dropbox.com/get/iOS%20Build%20Script%20Repo%20Images/config-configurations.png?_subject_uid=55388810&w=AAAWJmR_DjvGP46qo4YN0KMEXffYGmMcdIqLSdl7qLy6Uw)

<sup>B</sup>
![Config](https://dl-web.dropbox.com/get/iOS%20Build%20Script%20Repo%20Images/config-ad-hoc.png?_subject_uid=55388810&w=AAAHLK2sgVEV7RoWz5jsFngibKTnGtvgrLtacJyzE9m-3Q)

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

###Setting up upload.sh


<!--<sup>A</sup>-->
<!--![Config](https://dl-web.dropbox.com/get/iOS%20Build%20Script%20Repo%20Images/config-ad-hoc.png?_subject_uid=55388810&w=AAAHLK2sgVEV7RoWz5jsFngibKTnGtvgrLtacJyzE9m-3Q)-->
