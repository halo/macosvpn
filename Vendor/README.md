There are two reasons to have these dependencies vendorized in this directory.

1. The packages from the Swift Package Manager are not embedded into the test target.
   So basically, the test target never compiles.

2. Homebrew runs sandboxed, so it cannot download the dependencies.
