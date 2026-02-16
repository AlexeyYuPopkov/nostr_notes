fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

### relay_up

```sh
[bundle exec] fastlane relay_up
```

Start the test relay (postgres + redis + nostpy)

### relay_clean

```sh
[bundle exec] fastlane relay_clean
```

Truncate all relay tables (clean state for next test)

### relay_down

```sh
[bundle exec] fastlane relay_down
```

Stop the test relay

### integration_test

```sh
[bundle exec] fastlane integration_test
```

Run integration tests with a local relay

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
