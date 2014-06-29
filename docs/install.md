## INSTALLATION

### REQUIREMENTS

- Python v2.6+
- Supported shells:
    - bash v4.0+
    - zsh
    - fish
    - tcsh (experimental)
    - clink (Windows, experimental)

### AUTOMATIC

#### Linux

autojump is included in the following distro repositories, please use relevant
package management utilities to install (e.g. yum, apt-get, etc):

- Debian testing/unstable, Ubuntu, Linux Mint

    All Debian-derived distros require manual activation for policy reasons,
    please see `/usr/share/doc/autojump/README.Debian`.

- RedHat, Fedora, CentOS
- ArchLinux
- Gentoo
- Frugalware
- Slackware

#### OS X

Homebrew is the recommended installation method for Mac OS X:

    brew install autojump

MacPorts also available:

    port install autojump

## Windows

Windows support is enabled by [clink](https://code.google.com/p/clink/) which
should be installed prior to installing autojump.

### MANUAL

Grab a copy of autojump:

    git clone git://github.com/joelthelion/autojump.git

Run the installation script and follow on screen instructions.

    cd autojump
    ./install.py or ./uninstall.py
