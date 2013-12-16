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

from math import sqrt
from operator import itemgetter
import os
import platform
import sys

from argparse import ArgumentParser

from data import save
from data import load
from utils import decode
from utils import encode_local
from utils import is_osx

VERSION = 'release-v21.8.0'


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
    # TODO(ting|2013-12-15): what if data_home doesn't exist?
    # if 'AUTOJUMP_DATA_DIR' in os.environ:
        # config['data_home'] = os.environ.get('AUTOJUMP_DATA_DIR')
        # config['data_file'] = os.path.join(config['data_home'], 'autojump.pkl')

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
    # parser.add_argument(
            # '-d', '--decrease', metavar='WEIGHT', nargs='?', type=int,
            # const=15, default=False,
            # help='manually decrease path weight in database')
    # parser.add_argument(
            # '-b', '--bash', action="store_true", default=False,
            # help='enclose directory quotes to prevent errors')
    # parser.add_argument(
            # '--complete', action="store_true", default=False,
            # help='used for tab completion')
    # parser.add_argument(
            # '--purge', action="store_true", default=False,
            # help='delete all database entries that no longer exist on system')
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
        path, weight = add_path(config, os.getcwd(), args.increase)
        print(encode_local("%.1f:\t%s" % (weight, path)))
        sys.exit(0)

    # if args.decrease:
        # print("%.2f:\t old directory weight" % db.get_weight(os.getcwd()))
        # db.decrease(os.getcwd(), args.decrease)
        # print("%.2f:\t new directory weight" % db.get_weight(os.getcwd()))
        # sys.exit(0)

    # if args.purge:
        # removed = db.purge()

        # if len(removed):
            # for dir in removed:
                # output(dir)

        # print("Number of database entries removed: %d" % len(removed))

        # sys.exit(0)

    if args.stat:
        print_stats(config)
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


def print_stats(config):
    data = load(config)

    for path, weight in sorted(data.iteritems(), key=itemgetter(1)):
        print(encode_local("%.1f:\t%s" % (weight, path)))

    print("________________________________________\n")
    print("%d:\t total weight" % sum(data.itervalues()))
    print("%d:\t number of entries" % len(data))
    print("%.2f:\t current directory weight" % data.get(os.getcwd(), 0))

    print("\ndata:\t %s" % config['data_path'])


def main():
    config = parse_args(parse_env(set_defaults()))
    return 0

if __name__ == "__main__":
    sys.exit(main())
