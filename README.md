# Run a script when Setup Manager is finished

**Important Note**

The "run when finished" functionality is now built-in to Setup Manager since version [1.3](https://github.com/jamf/Setup-Manager/releases/tag/v1.3). No need to build your own LaunchDaemon any more. Just set the `finshedScript` or `finishedTrigger` key in the Setup Manager profile. [More details in the documentation.](https://github.com/jamf/Setup-Manager/blob/main/ConfigurationProfile.md#finishedscript)

[Download latest version of Setup Manager.](https://github.com/jamf/Setup-Manager/releases/latest)


*This repo is now archived.**

---

This is a launchDaemon that works with [Setup Manager](https://github.com/Jamf-Concepts/Setup-Manager) for Jamf Pro and Jamf School.

See [this blog post for background](https://scriptingosx.com/2025/01/run-a-script-when-setup-manager-is-finished/).

## Usage

Download the repo and adapt the [`setupManagerFinished.sh`](https://github.com/scriptingosx/SetupManagerFinishedScript/blob/main/payload/Library/Management/setupManagerFinished.sh) script to your needs. The code you want to adapt is [in lines 39 through 47](https://github.com/scriptingosx/SetupManagerFinishedScript/blob/d8a837172a6b8b9315480664c1d77749e3499450/payload/Library/Management/setupManagerFinished.sh#L39-L47).

The default script triggers a custom policy trigger (`setup_manager_finished`, defined [in line 10](https://github.com/scriptingosx/SetupManagerFinishedScript/blob/d8a837172a6b8b9315480664c1d77749e3499450/payload/Library/Management/setupManagerFinished.sh#L10))

The [`buildSetupManagerFinishedPkg.sh`](https://github.com/scriptingosx/SetupManagerFinishedScript/blob/d8a837172a6b8b9315480664c1d77749e3499450/buildSetupManagerFinishedPkg.sh) script will assemble the LaunchDaemon plist, the script and the installation scripts into a pkg.

You will have to adapt the name of the certificate you use to sign the pkg [in line 20](https://github.com/scriptingosx/SetupManagerFinishedScript/blob/d8a837172a6b8b9315480664c1d77749e3499450/buildSetupManagerFinishedPkg.sh#L20). If you do not have a signing certificate, you can set `signature=""` and the script will build an un-signed pkg. You need a signed installer pkg when you want to add it to the Jamf Pro Prestage or install it with Jamf School. But if the pkg is not signed, you can still install it with a Jamf Pro policy with a Setup Manager action. As long as it is installed before Setup Manager finishes, it will trigger when the flag file gets created.

## Support and Community

Code is provided as-is. You can join us on the [Mac Admins Slack](https://macadmins.org) in the  [#jamf-setup-manager](https://macadmins.slack.com/archives/C078DDLKRDW) channel for discussions.
