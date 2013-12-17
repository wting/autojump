#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
  Copyright © 2008-2012 Joel Schaerer
  Copyright © 2012-2013 William Ting

  *  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 3, or (at your option)
  any later version.

  *  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  *  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software
  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
"""

from __future__ import division, print_function

from collections import namedtuple
from functools import partial
from itertools import ifilter
from itertools import imap
from math import sqrt
from operator import attrgetter
from operator import itemgetter
import os
import platform
import sys

from argparse import ArgumentParser

from data import load
from data import save
from utils import decode
from utils import encode_local
from utils import first
from utils import is_osx
from utils import print_entry

VERSION = 'release-v21.8.0'
Entry = namedtuple('Entry', ['path', 'weight'])


def set_defaults():
    config = {}
    config['tab_menu_separator'] = '__'

    if is_osx():
        data_home = os.path.join(
                        os.path.expanduser('~'),
                        'Library',
                        'autojump')
    else:
        data_home = os.getenv(
                'XDG_DATA_HOME',
                os.path.join(
                        os.path.expanduser('~'),
                        '.local',
                        'share',
                        'autojump'))

    config['data_path'] = os.path.join(data_home, 'autojump.txt')
    config['backup_path'] = os.path.join(data_home, 'autojump.txt.bak')
    config['tmp_path'] = os.path.join(data_home, 'data.tmp')

    return config


def parse_env(config):
    # TODO(ting|2013-12-16): add autojump_data_dir support
    # TODO(ting|2013-12-15): add ignore case / smartcase support
    # TODO(ting|2013-12-15): add symlink support

    return config


def parse_args(config):
    parser = ArgumentParser(
            description='Automatically jump to directory passed as an argument.',
            epilog="Please see autojump(1) man pages for full documentation.")
    parser.add_argument(
            'directory', metavar='DIRECTORY', nargs='*', default='',
            help='directory to jump to')
    parser.add_argument(
            '-a', '--add', metavar='DIRECTORY',
            help='add path')
    parser.add_argument(
            '-i', '--increase', metavar='WEIGHT', nargs='?', type=int,
            const=20, default=False,
            help='increase current directory weight')
    parser.add_argument(
            '-d', '--decrease', metavar='WEIGHT', nargs='?', type=int,
            const=15, default=False,
            help='decrease current directory weight')
    # parser.add_argument(
            # '-b', '--bash', action="store_true", default=False,
            # help='enclose directory quotes to prevent errors')
    # parser.add_argument(
            # '--complete', action="store_true", default=False,
            # help='used for tab completion')
    parser.add_argument(
            '--purge', action="store_true", default=False,
            help='remove non-existent paths from database')
    parser.add_argument(
            '-s', '--stat', action="store_true", default=False,
            help='show database entries and their key weights')
    parser.add_argument(
            '-v', '--version', action="version", version="%(prog)s " +
            VERSION, help='show version information')

    args = parser.parse_args()

    if args.add:
        add_path(config, args.add)
        sys.exit(0)

    if args.increase:
        try:
            print_entry(add_path(config, os.getcwdu(), args.increase))
            sys.exit(0)
        except OSError:
            print("Current directory no longer exists.", file=sys.stderr)
            sys.exit(1)

    if args.decrease:
        try:
            print_entry(decrease_path(config, os.getcwdu(), args.decrease))
            sys.exit(0)
        except OSError:
            print("Current directory no longer exists.", file=sys.stderr)
            sys.exit(1)

    if args.purge:
        print("Purged %d entries." % purge_missing_paths(config))
        sys.exit(0)

    if args.stat:
        print_stats(config)
        sys.exit(0)

    print(encode_local(find_matches(config, args.directory)))
    sys.exit(0)

    # if args.complete:
        # config['match_cnt'] = 9
        # config['ignore_case'] = True

    # config['args'] = args
    return config


def add_path(config, path, increment=10):
    """Add a new path or increment an existing one."""
    path = decode(path).rstrip(os.sep)
    if path == os.path.expanduser('~'):
        return path, 0

    data = load(config)

    if path in data:
        data[path] = sqrt((data[path]**2) + (increment**2))
    else:
        data[path] = increment

    save(config, data)
    return path, data[path]


def decrease_path(config, path, increment=15):
    """Decrease weight of existing path."""
    path = decode(path).rstrip(os.sep)
    data = load(config)

    data[path] = max(0, data[path]-increment)

    save(config, data)
    return path, data[path]


def find_matches(config, needles, count=1):
    """Return [count] paths matching needles."""
    entriefy = lambda tup: Entry(*tup)
    exists = lambda entry: os.path.exists(entry.path)
    data = sorted(
            ifilter(exists, imap(entriefy, load(config).iteritems())),
            key=attrgetter('weight'),
            reverse=True)

    print(data[:3])

    # if no arguments, return first path
    if not needles:
        return first(data).path

    sanitize = lambda x: decode(x).rstrip(os.sep)
    needle = first(imap(sanitize, needles))

    exact_matches = match_exact(needle, data)

    return first(exact_matches).path


def match_exact(needle, haystack):
    find = lambda haystack: needle in haystack.path
    return ifilter(find, haystack)


def purge_missing_paths(config):
    """Remove non-existent paths."""
    exists = lambda x: os.path.exists(x[0])
    old_data = load(config)
    new_data = dict(ifilter(exists, old_data.iteritems()))
    save(config, new_data)
    return len(old_data) - len(new_data)


def print_stats(config):
    data = load(config)

    for path, weight in sorted(data.iteritems(), key=itemgetter(1)):
        print_entry(path, weight)

    print("________________________________________\n")
    print("%d:\t total weight" % sum(data.itervalues()))
    print("%d:\t number of entries" % len(data))

    try:
        print("%.2f:\t current directory weight" % data.get(os.getcwdu(), 0))
    except OSError:
        pass

    print("\ndata:\t %s" % config['data_path'])


def main():
    parse_args(parse_env(set_defaults()))
    return 0

if __name__ == "__main__":
    sys.exit(main())
