#!/usr/bin/env bash

pandoc -s -w man manpage.md -o autojump.1
pandoc -s -w markdown manpage.md INSTALL.md -o README.md
