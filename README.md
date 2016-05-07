[![Version](https://img.shields.io/github/tag/halo/macosvpn.svg?style=flat&label=version)](https://github.com/halo/macosvpn/releases)
[![Homebrew](https://img.shields.io/homebrew/v/macosvpn.svg?style=flat)](https://github.com/Homebrew/homebrew-core/blob/master/Formula/macosvpn.rb)
[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](https://github.com/halo/macosvpn/blob/master/LICENSE.md)
[![Build Status](https://travis-ci.org/halo/macosvpn.svg?branch=master)](https://travis-ci.org/halo/macosvpn)
[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/halo/macosvpn)

## Create Mac OS VPNs programmatically

This is a command-line tool written in Objective-C (transitioning to Swift) that can create VPN network configurations on your Mac.

It supports both L2TP over IPSec and Cisco IPSec.
Integration tests are run on Travis using Ruby rspec to ensure it's working.

![Screenshot](https://cdn.rawgit.com/halo/macosvpn/master/doc/screenshot_0.2.0-beta.png)

## Requirements

* Mac OS El Capitan, Yosemite, or Mavericks
* Administrator privileges (i.e. you've got to run it with sudo)

**Why sudo?**

The passwords of VPN services are stored in the System Keychain.
Only `sudo` or a [HelperTool](https://developer.apple.com/library/mac/documentation/Security/Conceptual/SecureCodingGuide/Articles/AccessControl.html#//apple_ref/doc/uid/TP40002589-SW2) can write to the System Keychain.
I don't want you to have to deal with the complexity a HelperTool can entail (GUI authorization and upgrading), so we simply use `sudo`.

## Installation

If you have [Homebrew](http://brew.sh) installed, you can simply start a Terminal and run:

```bash
brew install macosvpn
``

If not, you can run this curl command to get the compiled executable from Github:

```bash
sudo bash -c "curl -L https://github.com/halo/macosvpn/releases/download/0.1.4/macosvpn > /usr/local/bin/macosvpn"
sudo chmod +x /usr/local/bin/macosvpn
```

If that freaks you out (it should), you can compile it yourself if you have Xcode installed:

```bash
git clone https://github.com/halo/macosvpn.git
cd macosvpn
xcodebuild -configuration Debug
build/Debug/macosvpn --help
```

You can always run `macosvpn --version` to see the version currently installed on your system
and compare it to [the latest available version](https://github.com/halo/macosvpn/releases) on Github.

## Usage

Creating a single L2TP over IPSec VPN Service:

    sudo macosvpn create --l2tp Atlantic --endpoint atlantic.example.com --username Alice --password p4ssw0rd --shared-secret s3same

Replace `--l2tp` with `--cisco` to create a Cisco IPSec instead.  A Cisco IPSec groupname can be specified with `--groupname`.

When creating an L2TP service, you can add the `--split` flag to **not** force all traffic over VPN.

By default, enables the option "Send all traffic over VPN connection",
also known as wildcard routing.   To disable this option, include the `--split`
flag to use the VPN Service for specific routes only.  Split tunnelling may
require use of [`/etc/ppp/ip-up` and `/etc/ppp/ip-down` scripts](https://developer.apple.com/library/mac/documentation/Darwin/Reference/ManPages/man8/pppd.8.html).

#### Shortcuts

The same command but shorter:

    sudo macosvpn create l2tp Atlantic endpoint atlantic.example.com username Alice password p4ssw0rd shared-secret s3same

The same command even shorter:

    sudo macosvpn create -l Atlantic -e atlantic.example.com -u Alice -p p4ssw0rd -s s3same

The same command as short as possible:

    sudo macosvpn create -leups Atlantic atlantic.example.com Alice p4ssw0rd s3same

Simular command for Cisco VPN

    sudo macosvpn create -c Atlantic -e atlantic.example.com -u Alice -p p4ssw0rd -g EasyVPNGRoup -s s3same


#### Creating multiple VPNs at once

Repeat the arguments for creating multiple Services at once (no matter which short version you use :)

    sudo macosvpn create -leups Atlantic atlantic.example.com Alice p4ssw0rd s3same \\
                         -leups Northpole northpole.example.com Bob s3cret pr1v4te

#### Global default values

Assign default values which will be applied to every service. Say you want to create the following VPN services:

    no name      endpoint              user  password sharedsecret
    --------------------------------------------------------------
    1  Australia australia.example.com Alice p4ssw0rd s3same
    2  Island    island.example.com    Alice p4ssw0rd s3same

You could do that with the following command:

    sudo macosvpn create --default-username Alice --default-password p4ssw0rd --default-endpoint-suffix .example.com \\
                         --l2tp Australia --endpoint-prefix australia --shared-secret s3same \\
                         --l2tp Island --endpoint-prefix island --shared-secret letme1n

The same command a little shorter:

    sudo macosvpn create -m Alice -a p4ssw0rd -x .example.com \\
                         -l Australia -f australia -s s3same \\
                         -l Island -f island -s letme1n

If you feel adventurous you can find all available flags [at the bottom of this file](https://github.com/halo/macosvpn/blob/master/macosvpn/Classes/VPNArguments.m).

## Troubleshooting

* If you get a warning that says "Creating Keychain item failed: write permissions error", you need to run the application with `sudo`.
* If you're stuck, try to add the `--debug` flag and see if it says something useful.

## Limitations

* If a VPN with the given name already exists, a new one with an incremental number is created.
  In the future there should be a `--force` option to re-create it

## Development

The master branch is always edge and not ready for production.

Useful commands for debugging:

```bash
# Show all current VPN service configurations
open /Library/Preferences/SystemConfiguration/preferences.plist
```

```bash
# Show all Keychain Items and their access policies
security dump-keychain -a /Library/Keychains/System.keychain
```

Note to self: Compiling with "Release" configuration causes random crashes. It needs to be "Debug".
See https://github.com/halo/macosvpn/issues/13#issuecomment-217252496

## History and credits

Feel free to browse through the code of this application.
It's pretty small and straight-forward.

It all began with finding [this page](https://lists.apple.com/archives/macnetworkprog/2011/May/msg00032.html) you probably already found.
But it was not before [this practical example](https://lists.apple.com/archives/macnetworkprog/2013/Apr/msg00016.html) that I actually dared to try to implement this.
Then, google led me to [this page](https://lists.apple.com/archives/macnetworkprog/2007/Dec/msg00045.html) where I learned how to set the Shared Secret.
The last hurdle was to get the "Send all traffic over VPN" flag, which I finally [found the answer to here](http://pastebin.com/112KEHSV).
Finally, I [learned from over here](http://stackoverflow.com/questions/24363935) how to add things to the System Keychain.

## Special thanks

To the beautiful 3rd party libraries I was allowed to use:

* [NSError/ArgumentParser](https://github.com/NSError/ArgumentParser)
* [CocoaLumberjack](https://github.com/CocoaLumberjack/CocoaLumberjack)
* [beelsebob/CoreParse](https://github.com/beelsebob/CoreParse)

## License

MIT 2015 halo. See [MIT-LICENSE](https://github.com/halo/macosvpn/blob/master/LICENSE.md).
