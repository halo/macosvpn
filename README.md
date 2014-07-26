# macosvpn

This is a command-line tool written in Objective C that can create VPN network configurations. It currently only supports L2TP over IPSec. With a little bit of work, it should also be able to create Cisco IPsec VPN.

## Requirements

* Mac OS Mavericks (I developed it on Mavericks but it might work on other versions)
* Administrator privileges (i.e. you've got know the root password or run it with sudo)

## Quickstart

If you don't care for the details and want to get going without any thinking, you might try running this in a Terminal:

```bash
# TODO: Is this working yet?
# I'm trying to wrap the binary into a rubygem for easy installation
sudo gem install macosvpn

# Use this command to create a simple VPN service
sudo macosvpn create --l2tp MyVPN --endpoint server.example.com --username Alice --password p4ssw0rd --shared-secret s3same
``

Profit!

## Slowstart

Ah, I see you're more realistic than that and care for security. Nice. Let me suggest that you look at the source code and build the executable yourself using X-Code. If you're too lazy for that you can download the latest build here:

### Download

* [Latest build](https://github.com/halo/macosvpn/blob/master/macosvpn/bin/objectivemacosvpn).

Alternatively you may use curl to get the executable directly:

```bash
# TODO: figure out this command
sudo curl
FROM RAW https://github.com/halo/macosvpn/blob/master/macosvpn/bin/objectivemacosvpn
TO /usr/local/bin/macosvpn
sudo chmod +x /usr/local/bin/macosvpn
```

## Usage

Creating a single L2TP over IPSec VPN Service:

    macosvpn create --l2tp Atlantic --endpoint atlantic.example.com --username Alice --password p4ssw0rd --shared-secret s3same

#### Shortcuts

The same command but shorter:

    macosvpn create l2tp Atlantic endpoint atlantic.example.com username Alice password p4ssw0rd shared-secret s3same

The same command even shorter:

    macosvpn create -l Atlantic -e atlantic.example.com -u Alice -p p4ssw0rd -s s3same

The same command as short as possible:

    macosvpn create -leups Atlantic atlantic.example.com Alice p4ssw0rd s3same

#### Creating multiple VPNs at once

Repeat the arguments for creating multiple Services at once (no matter which short version you use :)

    macosvpn create -leups Atlantic atlantic.example.com Alice p4ssw0rd s3same \\
                    -leups Northpole northpole.example.com Bob s3cret pr1v4te

#### Global default values

Assign default values which will be applied to every service. Say you want to create the following VPN services:

    no name      endpoint              user  password sharedsecret
    --------------------------------------------------------------
    1  Australia australia.example.com Alice p4ssw0rd s3same
    2  Island    island.example.com    Alice p4ssw0rd s3same
    
You could do that with the following command:

    macosvpn create --default-username Alice --default-password p4ssw0rd --default-endpoint-suffix .example.com \\
                    --l2tp Australia --endpoint-prefix australia --shared-secret s3same \\
                    --l2tp Island --endpoint-prefix island --shared-secret letme1n

The same command a little shorter:

    macosvpn create -m Alice -a p4ssw0rd -x .example.com \\
                    -l Australia -f australia -s s3same \\
                    -l Island -f island -s letme1n

You can look at the available flags [in this file](https://github.com/halo/macosvpn/blob/master/macosvpn/Classes/VPNArguments.m).

## Limitations/Future work

* If a VPN with the given name already exists, it is ignored. In the future there should be a --force option to re-create it

## Development and credits

Feel free to browse through the code of this application. It's pretty small and straight-forward.

It all began with finding [this page](https://lists.apple.com/archives/macnetworkprog/2011/May/msg00032.html) you probably already found. But it was not before [this practical example](https://lists.apple.com/archives/macnetworkprog/2013/Apr/msg00016.html) that I actually dared to try to implement this. Then, google led me to [this page](https://lists.apple.com/archives/macnetworkprog/2007/Dec/msg00045.html) where I learned how to set the Shared Secret. The last hurdle was to get the "Send all traffic over VPN" flag, which I finally [found the answer to here](http://pastebin.com/112KEHSV). Finally, I [learned from over here](http://stackoverflow.com/questions/24363935) how to add things to the System Keychain.

Useful commands for debugging:

```bash
# Show all current VPN service configurations
open /Library/Preferences/SystemConfiguration/preferences.plist
```

```bash
# Show all Keychain Items and their access policies
security dump-keychain -a /Library/Keychains/System.keychain
```

## License

MIT 2014 funkensturm. See [MIT-LICENSE](https://github.com/halo/macosvpn/blob/master/LICENSE.md).

