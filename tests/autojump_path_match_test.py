# -*- coding: utf-8 -*-

import os
import sys

sys.path.append(os.path.join(os.getcwd(), 'bin'))

from autojump_data import Entry
import autojump_path_match as m


def test_match_fuzzy():
    needles = ['foo', 'bar']
    haystack = [
        Entry("/foo/bar/baz", 11),
        Entry("/foo/baz/moo", 10),
        Entry("/moo/foo/baz", 10),
    ]
    result = list(m.match_fuzzy(needles, haystack))
    assert result == [
        Entry("/foo/bar/baz", 11),
        Entry("/moo/foo/baz", 10),
    ]


def test_match_consecutive():
    needles = ['foo', 'baz']
    haystack = [
        Entry("/foo/bar/baz", 10),
        Entry("/foo/baz/moo", 10),
        Entry("/moo/foo/Baz", 10),
        Entry("/foo/bazar", 10),
        Entry("/foo/xxbaz", 10)
    ]
    result = list(m.match_consecutive(needles, haystack))
    assert result == [
        Entry("/foo/bazar", 10),
        Entry("/foo/xxbaz", 10)
    ]
    result = list(m.match_consecutive(needles, haystack, ignore_case=True))
    assert result == [
        Entry("/moo/foo/Baz", 10),
        Entry("/foo/bazar", 10),
        Entry("/foo/xxbaz", 10)
    ]
