import os
import re
import sys
from itertools import chain
from operator import attrgetter
from difflib import SequenceMatcher

from autojump_utils import (
    last,
    has_uppercase,
)

if sys.version_info[0] == 3:
    ifilter = filter
    imap = map
    os.getcwdu = os.getcwd
else:
    from itertools import ifilter
    from itertools import imap

FUZZY_MATCH_THRESHOLD = 0.6


def find_matches(entries, needles, check_entries=True):
    """Return an iterator to matching entries."""
    # TODO(wting|2014-02-24): replace assertion with unit test
    assert isinstance(needles, list), "Needles must be a list."
    ignore_case = detect_smartcase(needles)

    try:
        pwd = os.getcwdu()
    except OSError:
        pwd = None

    # using closure to prevent constantly hitting hdd
    def is_cwd(entry):
        return os.path.realpath(entry.path) == pwd

    if check_entries:
        path_exists = lambda entry: os.path.exists(entry.path)
    else:
        path_exists = lambda _: True

    data = sorted(
        entries,
        key=attrgetter('weight'),
        reverse=True)

    return ifilter(
        lambda entry: not is_cwd(entry) and path_exists(entry),
        chain(
            match_consecutive(needles, data, ignore_case),
            match_fuzzy(needles, data, ignore_case),
            match_anywhere(needles, data, ignore_case)))


def match_anywhere(needles, haystack, ignore_case=False):
    """
    Matches needles anywhere in the path as long as they're in the same (but
    not necessary consecutive) order.

    For example:
        needles = ['foo', 'baz']
        regex needle = r'.*foo.*baz.*'
        haystack = [
            (path="/foo/bar/baz", weight=10),
            (path="/baz/foo/bar", weight=10),
            (path="/foo/baz", weight=10)]

        result = [
            (path="/moo/foo/baz", weight=10),
            (path="/foo/baz", weight=10)]
    """
    regex_needle = '.*' + '.*'.join(needles).replace('\\', '\\\\') + '.*'
    regex_flags = re.IGNORECASE | re.UNICODE if ignore_case else re.UNICODE
    found = lambda haystack: re.search(
        regex_needle,
        haystack.path,
        flags=regex_flags)
    return ifilter(found, haystack)


def match_consecutive(needles, haystack, ignore_case=False):
    """
    Matches consecutive needles at the end of a path.

    For example:
        needles = ['foo', 'baz']
        haystack = [
            (path="/foo/bar/baz", weight=10),
            (path="/foo/baz/moo", weight=10),
            (path="/moo/foo/baz", weight=10),
            (path="/foo/baz", weight=10)]

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
            (path="/moo/foo/baz", weight=10),
            (path="/foo/baz", weight=10)]
    """
    reversed_needles = list(reversed(needles))
    for entry in haystack:
        path_segments = entry.path.split(os.sep)
        for target, needle_part in zip(
            reversed(path_segments), reversed_needles
        ):
            if ignore_case:
                needle_part = needle_part.lower()
                target = target.lower()
            if needle_part not in target:
                break
        else:
            yield entry


def match_fuzzy(needles, haystack, ignore_case=False):
    """
    Performs an approximate match with the last needle against the end of
    every path past an acceptable threshold (FUZZY_MATCH_THRESHOLD).

    For example:
        needles = ['foo', 'bar']
        haystack = [
            (path="/foo/bar/baz", weight=11),
            (path="/foo/baz/moo", weight=10),
            (path="/moo/foo/baz", weight=10),
            (path="/foo/baz", weight=10),
            (path="/foo/bar", weight=10)]

    result = [
            (path="/foo/bar/baz", weight=11),
            (path="/moo/foo/baz", weight=10),
            (path="/foo/baz", weight=10),
            (path="/foo/bar", weight=10)]

    This is a weak heuristic and used as a last resort to find matches.
    """
    needle = last(needles)
    if ignore_case:
        needle = needle.lower()

    for entry in haystack:
        _, tail = os.path.split(entry.path)
        path = tail.lower() if ignore_case else tail
        matcher = SequenceMatcher(a=needle, b=path)
        if matcher.ratio() >= FUZZY_MATCH_THRESHOLD:
            yield entry


def detect_smartcase(needles):
    """
    If any needles contain an uppercase letter then use case sensitive
    searching. Otherwise use case insensitive searching.
    """
    return not any(imap(has_uppercase, needles))
