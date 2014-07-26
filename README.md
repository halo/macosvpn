# macosvpn

This is a command-line tool written in Objective C that can create VPN network configurations. It currently only supports L2TP over IPSec. With a little bit of work, it should also be able to create Cisco IPsec VPN.

## Requirements

* Mac OS Mavericks (I developed it on Mavericks but it might work on other versions)
* Administrator privileges (i.e. you've got know the root password or run it with sudo)

## Quickstart

If you don't care for the details and want to get going without any thinking, you might try running this in a Terminal:

```bash
sudo gem install macosvpn
sudo macosvpn create --l2tp MyVPN --endpoint server.example.com --username Alice --password p4ssw0rd --shared-secret s3same
``

Profit!

## Slowstart

Ah, I see you're more realistic than that and care for security. Nice.

Let me suggest that you look at the source code and build the executable yourself using X-Code.




## Usage


## Limitations/Future work




### License

MIT 2014 funkensturm. See [MIT-LICENSE](https://github.com/halo/macosvpn/blob/master/LICENSE.md).



What helped me

`open /Library/Preferences/SystemConfiguration/preferences.plist`

`security dump-keychain -a /Library/Keychains/System.keychain`

The first outline
https://lists.apple.com/archives/macnetworkprog/2011/May/msg00032.html

Practical example and caveats
https://lists.apple.com/archives/macnetworkprog/2013/Apr/msg00016.html

How to set the Shared Secret
https://lists.apple.com/archives/macnetworkprog/2007/Dec/msg00045.html

How to send all traffic over VPN
http://pastebin.com/112KEHSV

How to add Keychain Items
http://stackoverflow.com/questions/24363935

