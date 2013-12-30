#!/usr/bin/env python2
# -*- coding: utf-8 -*-

from __future__ import print_function

from argparse import ArgumentParser
import os
import shutil
import sys


SUPPORTED_SHELLS = ('bash', 'zsh', 'fish')


def cp(src, dest, dryrun=False):
    print("copying file: %s -> %s" % (src, dest))
    if not dryrun:
        shutil.copy(src, dest)


def get_shell():
    return os.path.basename(os.getenv('SHELL'))


def mkdir(path, dryrun=False):
    print("creating directory:", path)
    if not dryrun and not os.path.exists(path):
        os.makedirs(path)


def parse_arguments():
    default_destdir = os.path.join(os.path.expanduser("~"), '.autojump')
    default_prefix = ''
    default_zshshare = 'functions'

    parser = ArgumentParser(
            description='Installs autojump globally for root users, otherwise \
                    installs in current user\'s home directory.')
    parser.add_argument(
            '-n', '--dryrun', action="store_true", default=False,
            help='simulate installation')
    parser.add_argument(
            '-d', '--destdir', metavar='DIR', default=default_destdir,
            help='set destination to DIR')
    parser.add_argument(
            '-p', '--prefix', metavar='DIR', default=default_prefix,
            help='set prefix to DIR')
    parser.add_argument(
            '-z', '--zshshare', metavar='DIR', default=default_zshshare,
            help='set zsh share destination to DIR')
    parser.add_argument(
            '-s', '--system', action="store_true", default=False,
            help='install system wide for all users')

    args = parser.parse_args()

    if sys.version_info[0] == 2 and sys.version_info[1] < 7:
        print("Python v2.7+ or v3.0+ required.", file=sys.stderr)
        sys.exit(1)

    if get_shell() not in SUPPORTED_SHELLS:
        print("Unsupported shell: %s" % os.getenv('SHELL'), file=sys.stderr)
        sys.exit(1)

    if args.system:
        if os.geteuid() != 0:
            print("Please rerun as root for system-wide installation.", file=sys.stderr)
            sys.exit(1)
        if args.destdir == default_destdir:
            args.destdir = '/'
        if args.prefix == default_prefix:
            args.prefix = '/usr/local'
        if args.zshshare == default_zshshare:
            args.zshshare = '/usr/share/zsh/site-functions'

    return args


def print_post_installation_message(etc_dir):
    rcfile = '~/.%src' % get_shell()
    aj_shell = '%s/autojump.%s' % (etc_dir, get_shell())
    print("\nPlease manually add the following line to %s:\n" % rcfile)
    print("\t[[ -s %s ]] && source %s\n" % (aj_shell, aj_shell))
    print("Please restart terminal(s) before running autojump.\n")


def main(args):
    if args.dryrun:
        print("Installing autojump to %s (DRYRUN)..." % args.destdir)
    else:
        print("Installing autojump to %s ..." % args.destdir)

    bin_dir = os.path.join(args.destdir, args.prefix, 'bin')
    etc_dir = os.path.join(args.destdir, 'etc/profile.d')
    doc_dir = os.path.join(args.destdir, args.prefix, 'share/man/man1')
    icon_dir = os.path.join(args.destdir, args.prefix, 'share/autojump')
    zshshare_dir = os.path.join(args.destdir, args.zshshare)

    mkdir(bin_dir, args.dryrun)
    mkdir(etc_dir, args.dryrun)
    mkdir(doc_dir, args.dryrun)
    mkdir(icon_dir, args.dryrun)
    mkdir(zshshare_dir, args.dryrun)

    cp('./bin/autojump', bin_dir, args.dryrun)
    cp('./bin/data.py', bin_dir, args.dryrun)
    cp('./bin/utils.py', bin_dir, args.dryrun)
    cp('./bin/autojump.sh', etc_dir, args.dryrun)
    cp('./bin/autojump.bash', etc_dir, args.dryrun)
    cp('./bin/autojump.fish', etc_dir, args.dryrun)
    cp('./bin/autojump.zsh', etc_dir, args.dryrun)
    cp('./bin/_j', zshshare_dir, args.dryrun)
    cp('./bin/icon.png', icon_dir, args.dryrun)
    cp('./docs/autojump.1', doc_dir, args.dryrun)

    # TODO(ting|2013-12-30): modify autojump.sh for custom installs

    print_post_installation_message(etc_dir)

if __name__ == "__main__":
    sys.exit(main(parse_arguments()))
