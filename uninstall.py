#!/usr/bin/env python2
# -*- coding: utf-8 -*-

from __future__ import print_function

from argparse import ArgumentParser
import os
import shutil
import sys


def parse_arguments():
    parser = ArgumentParser(
            description='Installs autojump globally for root users, otherwise \
                    installs in current user\'s home directory.')
    parser.add_argument(
            '-n', '--dryrun', action="store_true", default=False,
            help='simulate installation')
    parser.add_argument(
            '-d', '--destdir', metavar='DIR',
            help='set destination to DIR')
    parser.add_argument(
            '-p', '--prefix', metavar='DIR',
            help='set prefix to DIR')
    parser.add_argument(
            '-z', '--zshshare', metavar='DIR',
            help='set zsh share destination to DIR')

    return parser.parse_args()


def remove_system_installation(dryrun=False):
    default_destdir = '/'
    default_prefix = '/usr/local'
    default_zshshare = '/usr/share/zsh/site-functions'

    bin_dir = os.path.join(default_destdir, default_prefix, 'bin')
    etc_dir = os.path.join(default_destdir, 'etc/profile.d')
    doc_dir = os.path.join(default_destdir, default_prefix, 'share/man/man1')
    icon_dir = os.path.join(default_destdir, default_prefix, 'share/autojump')
    zshshare_dir = os.path.join(default_destdir, default_zshshare)

    if os.path.exists(os.path.join(bin_dir, 'autojump')):
        print("Found system installation.")
    else:
        return

    rm(os.path.join(bin_dir, 'autojump'), dryrun)
    rm(os.path.join(bin_dir, 'data.py'), dryrun)
    rm(os.path.join(bin_dir, 'utils.py'), dryrun)
    rm(os.path.join(etc_dir, 'autojump.sh'), dryrun)
    rm(os.path.join(etc_dir, 'autojump.bash'), dryrun)
    rm(os.path.join(etc_dir, 'autojump.fish'), dryrun)
    rm(os.path.join(etc_dir, 'autojump.zsh'), dryrun)
    rm(os.path.join(zshshare_dir, '_j'), dryrun)
    rmdir(icon_dir, dryrun)
    rm(os.path.join(doc_dir, 'autojump.1'), dryrun)


def remove_user_installation(dryrun=False):
    default_destdir = os.path.join(os.path.expanduser("~"), '.autojump')
    if os.path.exists(default_destdir):
        print("Found user installation.")
        rmdir(default_destdir, dryrun)


def rm(path, dryrun):
    if os.path.exists(path):
        print("deleting file:", path)
        if not dryrun:
            shutil.rmtree(path)


def rmdir(path, dryrun):
    if os.path.exists(path):
        print("deleting directory:", path)
        if not dryrun:
            shutil.rmtree(path)


def main(args):
    if args.dryrun:
        print("Uninstalling autojump (DRYRUN)...")
    else:
        print("Uninstalling autojump...")

    remove_user_installation(args.dryrun)
    remove_system_installation(args.dryrun)


if __name__ == "__main__":
    sys.exit(main(parse_arguments()))
