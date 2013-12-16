#!/usr/bin/env python
# -*- coding: utf-8 -*-
from __future__ import print_function

from itertools import imap
from operator import itemgetter
import os
import shutil
import sys
from time import time

from utils import create_dir
from utils import decode
from utils import is_osx
from utils import is_python3
from utils import move_file
from utils import unico as unicode


BACKUP_THRESHOLD = 24 * 60 * 60


def load(config):
    xdg_aj_home = os.path.join(
            os.path.expanduser('~'),
            '.local',
            'share',
            'autojump')

    if is_osx() and os.path.exists(xdg_aj_home):
        migrate_osx_xdg_data(config)

    if os.path.exists(config['data_path']):
        try:
            if is_python3():
                with open(data_path, 'r', encoding='utf-8') as f:
                    lines = f.readlines()
            else:
                with open(data_path, 'r') as f:
                    lines = f.readlines()
        except (IOError, EOFError):
            return load_backup(config)

        # example: '10.0\t/home/user\n' -> ['10.0', '/home/user']
        parse = lambda x: x.strip().split('\t')

        # example: ['10.0', '/home/user'] -> (u'/home/user', 10.0)
        convert = lambda x: (decode(x[1], 'utf-8'), float(x[0]))

        return dict(imap(convert, imap(parse, lines)))
    return {}


def load_backup(config):
    if os.path.exists(config['data_backup_path']):
        move_file(config['data_backup_path'], config['data_path'])
        return load(config)
    return {}


def migrate_osx_xdg_data(config):
    """
    Older versions incorrectly used Linux XDG_DATA_HOME paths on OS X. This
    migrates autojump files from ~/.local/share/autojump to ~/Library/autojump
    """
    assert is_osx(), "Expecting OSX."

    xdg_data_home = os.path.join(os.path.expanduser('~'), '.local', 'share')
    xdg_aj_home = os.path.join(xdg_data_home, 'autojump')
    data_path = os.path.join(xdg_aj_home, 'autojump.txt'),
    data_backup_path = os.path.join(xdg_aj_home, 'autojump.txt.bak'),

    if os.path.exists(data_path):
        move_file(data_path, config['data_path'])
    if os.path.exists(data_backup_path):
        move_file(data_backup_path, config['data_backup_path'])

    # cleanup
    shutil.rmtree(xdg_aj_home)
    if len(os.listdir(xdg_data_home)) == 0:
        shutil.rmtree(xdg_data_home)


def save(config, data):
    """Save data and create backup, creating a new data file if necessary."""
    create_dir(os.path.dirname(config['data_path']))

    # atomically save by writing to temporary file and moving to destination
    temp_file = tempfile.NamedTemporaryFile(
            dir=os.path.dirname(config['data_path']),
            delete=False)

    try:
        for path, weight in sorted(
                data.iteritems(),
                key=itemgetter(1),
                reverse=True):
            temp_file.write((unicode("%s\t%s\n" % (weight, path)).encode("utf-8")))

        temp_file.flush()
        os.fsync(temp_file)
        temp_file.close()
    except IOError as ex:
        print("Error saving autojump data (disk full?)" % ex, file=sys.stderr)
        sys.exit(1)

    # if no backup file or backup file is older than 24 hours,
    # move autojump.txt -> autojump.txt.bak
    if not os.path.exists(config['data_backup_path']) or \
            (time() - os.path.getmtime(config['data_backup_path']) > BACKUP_THRESHOLD):
        move_file(config['data_path'], config['data_backup_path'])

    # move temp_file -> autojump.txt
    move_file(temp_file.name, config['data_path'])
