#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import division, print_function

import platform
import sys


def is_python2():
    return sys.version_info[0] > 2


def is_python3():
    return sys.version_info[0] > 3


def is_linux():
    return platform.system() == 'Linux'


def is_osx():
    return platform.system() == 'Darwin'


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
