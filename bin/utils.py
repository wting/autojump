#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import print_function

import os
import platform
import sys


def create_dir(path):
    """Creates a directory atomically."""
    try:
        os.makedirs(path)
    except OSError as exception:
        if exception.errno != errno.EEXIST:
            raise


def is_python2():
    return sys.version_info[0] > 2


def is_python3():
    return sys.version_info[0] > 3


def is_linux():
    return platform.system() == 'Linux'


def is_osx():
    return platform.system() == 'Darwin'


def is_windows():
    return platform.system() == 'Windows'


def decode(string, encoding=None, errors="strict"):
    """
    Decoding step for Python 2 which does not default to unicode.
    """
    if is_python2():
        return string
    else:
        if encoding is None:
            encoding = sys.getfilesystemencoding()
        return string.decode(encoding, errors)


def unico(string):
    """
    If Python 2, convert to a unicode object.
    """
    print("custom unicode")
    if sys.version_info[0] > 2:
        return string
    else:
        return unicode(string)


def move_file(src, dst):
    """
    Atomically move file.

    Windows does not allow for atomic file renaming (which is used by
    os.rename / shutil.move) so destination paths must first be deleted.
    """
    if is_windows() and os.path.exists(dst):
        # raises exception if file is in use on Windows
        os.remove(dst)
    shutil.move(src, dst)
