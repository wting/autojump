#!/usr/bin/env python
# -*- coding: utf-8 -*-

from itertools import imap
import os
import pickle
import platform
import shutil
import sys

from utils import decode
from utils import is_osx
from utils import is_python3
from utils import unico as unicode


def load(config):
    xdg_aj_home = os.path.join(
            os.path.expanduser('~'),
            '.local',
            'share',
            'autojump')
    legacy_data_file = os.path.join(xdg_aj_home, 'autojump.txt')

    # Older versions incorrectly used Linux XDG_DATA_HOME paths on OS X
    if is_osx() and os.path.exists(xdg_aj_home):
        return migrate_legacy_data(config)
    elif os.path.exists(legacy_data_file):
        return migrate_legacy_data(config)
    elif os.path.exists(config['data_file']):
        return load_pickle(config)
    return {}


def load_pickle(config):
    with open(config['data_file'], 'rb') as f:
        data = pickle.load(f)
    return data


def migrate_legacy_data(config):
    xdg_data_home = os.path.join(os.path.expanduser('~'), '.local', 'share')
    xdg_aj_home = os.path.join(xdg_data_home, 'autojump')
    legacy_data = os.path.join(xdg_aj_home, 'autojump.txt')
    legacy_data_backup = os.path.join(xdg_aj_home, 'autojump.bak')

    assert(os.path.exists(xdg_aj_home), "$XDG_DATA_HOME doesn't exist.")

    # migrate to new file format
    data = load_legacy(legacy_data, legacy_data_backup)
    save(config, data)

    # cleanup
    if is_osx():
        shutil.rmtree(xdg_aj_home)
        if len(os.listdir(xdg_data_home)) == 0:
            shutil.rmtree(xdg_data_home)
    else:
        if os.path.exists(legacy_data):
            os.remove(legacy_data)
        if os.path.exists(legacy_data_backup):
            os.remove(legacy_data_backup)

    return data


def load_legacy(data_file, data_file_backup):
    """Loads data from legacy data file."""
    try:
        if is_python3():
            with open(data_file, 'r', encoding='utf-8') as f:
                lines = f.readlines()
        else:
            with open(data_file, 'r') as f:
                lines = f.readlines()
    except (IOError, EOFError):
        return load_legacy_backup(data_file_backup)

    # example: '10.0\t/home/user\n' -> ['10.0', '/home/user']
    parse = lambda x: x.strip().split('\t')
    # example: ['10.0', '/home/user'] -> (u'/home/user', 10.0)
    convert = lambda x: (decode(x[1], 'utf-8'), float(x[0]))

    return dict(imap(convert, imap(parse, lines)))


def load_legacy_backup(data_file, data_file_backup):
    """Loads data from backup data file."""
    if os.path.exists(data_file_backup):
        shutil.move(data_file_backup, data_file)
        return load_legacy(data_file, None)
    return {}


def save(self):
    """
    Save database atomically and preserve backup, creating new database if
    needed.
    """
    # check file existence and permissions
    if ((not os.path.exists(self.filename)) or
            os.name == 'nt' or
            os.getuid() == os.stat(self.filename)[4]):

        create_dir_atomically(self.config['data'])

        temp = tempfile.NamedTemporaryFile(
                dir=self.config['data'],
                delete=False)

        for path, weight in sorted(self.data.items(),
                key=operator.itemgetter(1),
                reverse=True):
            temp.write((unico("%s\t%s\n" % (weight, path)).encode("utf-8")))

        # catching disk errors and skipping save when file handle can't
        # be closed.
        try:
            # http://thunk.org/tytso/blog/2009/03/15/dont-fear-the-fsync/
            temp.flush()
            os.fsync(temp)
            temp.close()
        except IOError as ex:
            print("Error saving autojump database (disk full?)" %
                    ex, file=sys.stderr)
            return

        shutil.move(temp.name, self.filename)
        try: # backup file
            import time
            if (not os.path.exists(self.filename+".bak") or
                    time.time()-os.path.getmtime(self.filename+".bak") \
                            > 86400):
                shutil.copy(self.filename, self.filename+".bak")
        except OSError as ex:
            print("Error while creating backup autojump file. (%s)" %
                    ex, file=sys.stderr)

