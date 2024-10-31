#!/bin/sh

# Setup Manager Finished

# this script is triggered by a LaunchD plist when flag file changes

export PATH=/usr/bin:/bin:/usr/sbin:/sbin

# variables
jamf_custom_trigger="setup_manager_finished"

flagFilePath="/private/var/db/.JamfSetupEnrollmentDone"

identifier="com.jamf.setupmanager.finished"
launchDaemonPath="/Library/LaunchDaemons/${identifier}.plist"

# start
echo "$identifier: watchPath $flagFilePath triggered"

# only run if flagFile exists

if [ ! -f "$flagFilePath" ]; then
  echo "$flagFilePath does not exist, exiting"
  exit 0
fi

sleep 2

# first, wait until jamf process is done, to let SM finish last recon
while pgrep -xq jamf; do
  echo "waiting for jamf process to finish..."
  sleep 2
done

# wait just a bit more for good measure
sleep 2


# put your actions here

# e.g. run a custom policy trigger
echo "running jamf policy trigger $jamf_custom_trigger"
/usr/local/jamf/bin/jamf policy -trigger "$jamf_custom_trigger"

# e.g. force a restart in 5 seconds
echo "restarting in 5s..."
shutdown -r +5s

# only run once, remove and unload launchd plist
rm -f "$launchDaemonPath"

echo "unloading launchDaemon for $identifier"
launchctl unload "$launchDaemonPath"
