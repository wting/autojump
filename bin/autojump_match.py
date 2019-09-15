#!/usr/bin/env python
# -*- coding: utf-8 -*-
import os
import re
from difflib import SequenceMatcher
from sys import stderr

from autojump_utils import is_python3
from autojump_utils import last

if is_python3():  # pragma: no cover
    ifilter = filter
    imap = map
    os.getcwdu = os.getcwd
else:
    from itertools import ifilter
    from itertools import imap


def match_anywhere(needles, haystack, ignore_case=False):
    """
    Matches needles anywhere in the path as long as they're in the same (but
    not necessary consecutive) order.

    For example:
        needles = ['foo', 'baz']
        regex needle = r'.*foo.*baz.*'
        haystack = [
            (path='/foo/bar/baz', weight=10),
            (path='/baz/foo/bar', weight=10),
            (path='/foo/baz', weight=10),
        ]

        result = [
            (path='/moo/foo/baz', weight=10),
            (path='/foo/baz', weight=10),
        ]
    """
    regex_needle = ".*" + ".*".join(imap(re.escape, needles)) + ".*"
    regex_flags = re.IGNORECASE | re.UNICODE if ignore_case else re.UNICODE
    found = lambda haystack: re.search(regex_needle, haystack.path, flags=regex_flags)
    return ifilter(found, haystack)


def match_consecutive(needles, haystack, ignore_case=False):
    """
    Matches consecutive needles at the end of a path.

    For example:
        needles = ['foo', 'baz']
        haystack = [
            (path='/foo/bar/baz', weight=10),
            (path='/foo/baz/moo', weight=10),
            (path='/moo/foo/baz', weight=10),
            (path='/foo/baz', weight=10),
        ]

        # We can't actually use re.compile because of re.UNICODE
        regex_needle = re.compile(r'''
            foo     # needle #1
            [^/]*   # all characters except os.sep zero or more times
            /       # os.sep
            [^/]*   # all characters except os.sep zero or more times
            baz     # needle #2
            [^/]*   # all characters except os.sep zero or more times
            $       # end of string
            ''')

        result = [
            (path='/moo/foo/baz', weight=10),
            (path='/foo/baz', weight=10),
        ]
    """
    regex_needle = ""
    for needle in needles:
        slash_only_needle = re.sub(re.escape(os.sep), "/", needle)
        if regex_needle == "":
            regex_needle = slash_only_needle
        else:
            regex_needle += "[^/]*/.*" + slash_only_needle
    regex_needle += "[^/]*$"
    regex_flags = re.IGNORECASE | re.UNICODE if ignore_case else re.UNICODE
    stderr.write("Regex: " + regex_needle + "\n")

    def found(entry):
        slash_only_path = re.sub(re.escape(os.sep), "/", entry.path)
        return re.search(regex_needle, slash_only_path, flags=regex_flags)

    return ifilter(found, haystack)


def match_fuzzy(needles, haystack, ignore_case=False, threshold=0.6):
    """
    Performs an approximate match with the last needle against the end of
    every path past an acceptable threshold.

    For example:
        needles = ['foo', 'bar']
        haystack = [
            (path='/foo/bar/baz', weight=11),
            (path='/foo/baz/moo', weight=10),
            (path='/moo/foo/baz', weight=10),
            (path='/foo/baz', weight=10),
            (path='/foo/bar', weight=10),
        ]

    result = [
            (path='/foo/bar/baz', weight=11),
            (path='/moo/foo/baz', weight=10),
            (path='/foo/baz', weight=10),
            (path='/foo/bar', weight=10),
        ]

    This is a weak heuristic and used as a last resort to find matches.
    """
    end_dir = lambda path: last(os.path.split(path))
    if ignore_case:
        needle = last(needles).lower()
        match_percent = lambda entry: SequenceMatcher(a=needle, b=end_dir(entry.path.lower())).ratio()
    else:
        needle = last(needles)
        match_percent = lambda entry: SequenceMatcher(a=needle, b=end_dir(entry.path)).ratio()
    meets_threshold = lambda entry: match_percent(entry) >= threshold
    return ifilter(meets_threshold, haystack)
