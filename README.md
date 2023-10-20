# Bazel rules for postgresql

## Features

* Download and install postgresql hermetically, as a toolchain*
* Creates a new postgresql cluster, with a new data directory, for each test
* Supports multiple versions of postgresql (though only 15.3 added for now)
* Supports multiple operating systems (linux, macos, windows)
* Supports multiple architectures (x86_64, arm64)

## Future

* Add support for random port selection

## Installation

From the release you wish to use:
<https://github.com/jacobshirley/rules_postgresql/releases>
copy the WORKSPACE snippet into your `WORKSPACE` file.

To use a commit rather than a release, you can point at any SHA of the repo.

For example to use commit `abc123`:

1. Replace `url = "https://github.com/jacobshirley/rules_postgresql/releases/download/v0.1.0/rules_postgresql-v0.1.0.tar.gz"` with a GitHub-provided source archive like `url = "https://github.com/jacobshirley/rules_postgresql/archive/abc123.tar.gz"`
1. Replace `strip_prefix = "rules_postgresql-0.1.0"` with `strip_prefix = "rules_postgresql-abc123"`
1. Update the `sha256`. The easiest way to do this is to comment out the line, then Bazel will
   print a message with the correct value. Note that GitHub source archives don't have a strong
   guarantee on the sha256 stability, see
   <https://github.blog/2023-02-21-update-on-the-future-stability-of-source-code-archives-and-hashes/>

## Usage

See e2e/smoke for an example of how to use the rules. Note only `postgresql_server_test` is supported at the moment.
See docs/ for info on the arguments to the rules.