#!/bin/bash

# Setup Manager Finished

# this script is triggered by a LaunchD plist when flag file changes

export PATH=/usr/bin:/bin:/usr/sbin:/sbin

# use osascript/JXA to get defaults values

MANAGED_PREFERENCE_DOMAIN="com.jamf.setupmanager"

getPref() { # $1: key, $2: default value, $3: domain
	local key=${1:?"key required"}
	local defaultValue=${2-:""}
	local domain=${3:-"$MANAGED_PREFERENCE_DOMAIN"}
	
    value=$(osascript -l JavaScript \
        -e "$.NSUserDefaults.alloc.initWithSuiteName('$domain').objectForKey('$key').js")
    
    if [[ -n $value ]]; then
    	echo "$value"
    else
    	echo "$defaultValue"
    fi
}

getPrefIsManaged() { # $1: key, $2: domain
	local key=${1:?"key required"}
	local domain=${2:-"$MANAGED_PREFERENCE_DOMAIN"}
    
    result=$(osascript -l JavaScript -e "$.NSUserDefaults.alloc.initWithSuiteName('$domain').objectIsForcedForKey('$key')")
    if [[ "$result" ==  "true" ]]; then
    	return 0
    else
    	return 1
    fi
}

cleanupAndExit() {
	# only run once, remove and unload launchd plist
	rm -f "$launchDaemonPath"
	
	echo "unloading launchDaemon for $identifier"
	launchctl unload "$launchDaemonPath"
	
	exit 0
}


# variables

if getPrefIsManaged "finishedTrigger"; then
	jamf_custom_trigger=$(getPref "finishedTrigger")
	echo "Finished Trigger: $jamf_custom_trigger"
fi

if getPrefIsManaged "finishedScript"; then
    script_path=$(getPref "finishedScript")
    echo "Finished Script: $script_path"
fi

if [[ "$jamf_custom_trigger" == "" && "$script_path" == "" ]]; then
	echo "no configurations found, exiting..."
	cleanupAndExit
fi

flagFilePath="/private/var/db/.JamfSetupEnrollmentDone"

identifier="com.jamf.setupmanager.finished"
launchDaemonPath="/Library/LaunchDaemons/${identifier}.plist"

# start
echo "$identifier: watchPath $flagFilePath triggered"

# only run if flagFile exists

if [ ! -f "$flagFilePath" ]; then
  echo "$flagFilePath does not exist, exiting"
  cleanUpAndExit
fi

sleep 2

# first, wait until jamf process is done, to let SM finish last recon
while pgrep -xq jamf; do
  echo "waiting for jamf process to finish..."
  sleep 5
done

# wait just a bit more for good measure
sleep 2

# run custom jamf trigger
jamf="/usr/local/jamf/bin/jamf"
if [[ -x "$jamf" && "$jamf_custom_trigger" != "" ]]; then
	echo "running jamf policy trigger $jamf_custom_trigger"
	$jamf policy -trigger "$jamf_custom_trigger" -verbose 
fi

# run custom script_path
if [[ "$script_path" != "" ]]; then

	# check executable
	if [[ -x "$script_path" ]]; then
		echo "$script_path is not executable"
		cleanUpAndExit
	fi

    # check owner
    if [[ $(stat -f "%Sp %Su:%Sg" "$script_path") != "root:wheel" ]]; then
    	echo "owner for $script_path not 'root:wheel'"
    	cleanupAndExit
	fi
	
	# check writable
	if [[ $(stat -f "%Sp" "$script_path") == ?????w???? ]]; then
		echo "$script_path must not be group writable"
		cleanupAndExit
	fi 
	if [[ $(stat -f "%Sp" "$script_path") == ????????w? ]]; then
		echo "$script_path must not be world writable"
		cleanupAndExit
	fi 
	
	# finally, run the script
	echo "running script $script_path"
	"#script_path"
fi

cleanUpAndExit