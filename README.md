[![Version](https://img.shields.io/github/tag/halo/macosvpn.svg?style=flat&label=version)](https://github.com/halo/macosvpn/releases)
[![Homebrew](https://img.shields.io/homebrew/v/macosvpn.svg?style=flat)](https://github.com/Homebrew/homebrew-core/blob/master/Formula/macosvpn.rb)
[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](https://github.com/halo/macosvpn/blob/master/LICENSE.md)
[![Build Status](https://travis-ci.org/halo/macosvpn.svg?branch=master)](https://travis-ci.org/halo/macosvpn)
[![Codebeat](https://codebeat.co/badges/b60656d2-1cc8-4644-a1a9-4a35177476fb)](https://codebeat.co/projects/github-com-halo-macosvpn)
[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/halo/macosvpn)
![Swift](https://img.shields.io/badge/Swift-5-F16D39.svg?style=flat)

## Create Mac OS VPNs programmatically

This is a command-line tool written in Swift that can create VPN network configurations on your Mac.

It supports **L2TP over IPSec** and **Cisco IPSec**.
Integration tests are run on Travis to ensure it's working properly.

This open-source code is actively maintained. Should you like to motivate me, you may click on the ✭ in the top-right corner.

![Screenshot](https://cdn.rawgit.com/halo/macosvpn/master/doc/screenshot_1.0.0-rc1.jpg)

## Requirements

* macoS 10.10 or higher
* Administrator privileges (i.e. you *have* to run it with sudo)

**Why sudo?**

The passwords of VPN services are exclusively stored in the *System Keychain*.
Only `sudo` or a [HelperTool](https://developer.apple.com/library/mac/documentation/Security/Conceptual/SecureCodingGuide/Articles/AccessControl.html#//apple_ref/doc/uid/TP40002589-SW2) can write to the *System Keychain*.
I don't want you to have to deal with the complexity a HelperTool can entail, so we simply use `sudo`.

## Installation

If you have [Homebrew](http://brew.sh) installed, you can simply start a Terminal and run:

```bash
# To see which version is installed via homebrew, have a look at:
# https://github.com/Homebrew/homebrew-core/search?q=macosvpn&type=Issues

brew install macosvpn
```

If not, you can run this curl command to get the compiled executable from Github:

```bash
# Make sure first that the directory /usr/local/bin exists

sudo sh -c "curl -L https://github.com/halo/macosvpn/releases/download/1.0.0/macosvpn > /usr/local/bin/macosvpn"
sudo chmod +x /usr/local/bin/macosvpn
```

As of macOS Catalina you may once have to "accept" that this executable is considered "safe":

```bash
xattr -d com.apple.quarantine /usr/local/bin/macosvpn
```

If that freaks you out (it should), you can compile it yourself if you have Xcode 11 installed:

```bash
git clone https://github.com/halo/macosvpn.git
cd macosvpn
bin/build
```

You can always run `macosvpn --version` to see the version currently installed on your system
and compare it to [the latest available version](https://github.com/halo/macosvpn/releases) on Github.

## Usage

Creating a single L2TP over IPSec VPN Service:

```sh
sudo macosvpn create --l2tp Atlantic --endpoint example.com --username Alice \
                     --password p4ssw0rd --sharedsecret s3same
```

* Replace `--l2tp` with `--cisco` to create a Cisco IPSec instead.
* Groupnames can be specified with `--groupname`.
* Add `--force` to overwrite an existing VPN with the same name.

By default, L2TP is created with the "Send all traffic over VPN connection" option, also known as wildcard routing.
You can add the `--split` flag to **not** force all traffic over VPN.

The same command shorter (try out `--help` to see all available arguments):

```sh
sudo macosvpn create -l Atlantic -e example.com -u Alice -p p4ssw0rd -s s3same
```

With L2TP you can

* add `--split` to *not* force all traffic over VPN.
* add `--disconnectswitch` to disconnect when switching user accounts.
* add `--disconnectlogout` to disconnect when user logs out.

#### Creating multiple VPNs at once

Repeat the arguments to create multiple Services at once.

```sh
sudo macosvpn create -c Atlantic -e atlantic.example.com -u Alice -p p4ssw0rd \
                     -l Pacific -e pacific.example.com -u Bob -p s3same
```

#### Deleting VPN services

```sh
sudo macosvpn delete --name MyVPN
sudo macosvpn delete -n AnotherOne -n ThisOneToo
sudo macosvpn delete --all # Careful!
```

## Troubleshooting

* If you're stuck, try to add the `--debug` flag and see if it says something useful.

## Limitations

* It is not possible to add so called "configurations" for L2TP. See [this issue](https://github.com/halo/macosvpn/issues/17).

## Development

The `master` branch is always edge and may not be ready for production.

There are XCTest units test and integration tests that are run using ruby. Simply look at [bin/test](https://github.com/halo/macosvpn/blob/master/bin/test) to see how to run the tests on your Mac.

Useful commands for debugging:

```bash
# Show all current VPN service configurations
open /Library/Preferences/SystemConfiguration/preferences.plist
```

```bash
# Show all Keychain Items and their access policies
security dump-keychain -a /Library/Keychains/System.keychain
```

## History and credits

Feel free to browse through the code of this application.
It's pretty small and straight-forward.

It all began with finding [this page](https://lists.apple.com/archives/macnetworkprog/2011/May/msg00032.html) you probably already found.
But it was not before [this practical example](https://lists.apple.com/archives/macnetworkprog/2013/Apr/msg00016.html) that I actually dared to try to implement this.
Then, google led me to [this page](https://lists.apple.com/archives/macnetworkprog/2007/Dec/msg00045.html) where I learned how to set the Shared Secret.
The last hurdle was to get the "Send all traffic over VPN" flag, which I finally [found the answer to here](http://pastebin.com/112KEHSV).
Finally, I [learned from over here](http://stackoverflow.com/questions/24363935) how to add things to the System Keychain.

## Special thanks

Thank you for reporting bugs. And thanks to all keen [contributors](https://github.com/halo/macosvpn/graphs/contributors).

These are 3rd-party libraries, which were kindly released under the MIT license:

* [Moderator](https://github.com/kareman/Moderator) by Kare Morstol
* [PrettyColors](https://github.com/jdhealy/PrettyColors) by J.D. Healy

## License

MIT 2014-2019 halo. See [MIT-LICENSE](https://github.com/halo/macosvpn/blob/master/LICENSE.md).
