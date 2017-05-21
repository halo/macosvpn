# master

Internal:

* Compatibility with Xcode 8.3.2 with Swift 3.1

# 0.3.1

Bugfix:

* Resolving an issue where L2TP Keychain Items were not associated with their network service.

Breaking Changes:

* Most exit codes changed so as to introduce a consistent numbering sequence.

# 0.3.0

Bugfix/Features:

* macOS Sierra compatibility (might break El Capitan, needs more testing)

# 0.2.1

Bugfix:

* Homebrew has the buggy "Release" configuration in `0.2.0` which has now been fixed. So we need a new version.

## 0.2.0

Removed:

* The `--default...` and `...prefix` flags are no longer supported (too buggy)

Features:

* Use `--force` to overwrite an existing VPN
* Added colors to help text
* Improved help text to be more understandable

Internal:

* Converted more classes to Swift

## 0.1.4

Bugfix:

* Don't crash randomly, see #13

## 0.1.3

Features:

* Added support for `--split` flag to not force traffic over VPN. (thanks to https://github.com/steve-jansen)
* Username and password are now optional
* Fixed a random crash issue that was introduced in `0.1.1`

## 0.1.2

Features:

* Improved help and debugging logs
* Fixed some typos

## 0.1.1

Features:

* Added support for Cisco IPSec group names (thanks to https://github.com/arnieggertsson)
* Some help text and README improvements

## 0.1.0

Features:

* Added support for Cisco IPSec

Changes:

* Changed a few error return codes in the 30s and introduced new error codes in the 50s

## 0.0.4

Features:

  * Improved debugging output
  * Got rid of all compiler warnings

## 0.0.3

Bugfixes:

  * Properly respect the `--username` flag. Thanks to @callmeflinx.

## 0.0.2

No significant changes, just experimenting.

## 0.0.1

Features:

  * Boom! Introduced first version.
