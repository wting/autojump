#!/usr/bin/env python
# -*- coding: utf-8 -*-
import os
import sys

import pytest

sys.path.append(os.path.join(os.getcwd(), 'bin'))  # noqa
from autojump_data import Entry
from autojump_match import match_anywhere


class TestMatchAnywhere(object):

    entry1 = Entry('/foo/bar/baz', 10)
    entry2 = Entry('/baz/foo/bar', 10)
    entry3 = Entry('/foo/baz', 10)
    entry4 = Entry('/中/zhong/国/guo', 10)
    entry5 = Entry('/is\'t/this/a/b*tchin/edge/case?', 10)
    win_entry1 = Entry('C:\\foo\\bar\\baz', 10)
    win_entry2 = Entry('D:\Program Files (x86)\GIMP', 10)
    win_entry3 = Entry('C:\Windows\System32', 10)

    @pytest.fixture
    def haystack(self):
        return [
            self.entry1,
            self.entry2,
            self.entry3,
            self.entry4,
            self.entry5,
        ]

    @pytest.fixture
    def windows_haystack(self):
        return [self.win_entry1, self.win_entry2, self.win_entry3]

    def test_single_needle(self, haystack):
        assert list(
            match_anywhere(
                ['bar'],
                haystack)) == [
            self.entry1,
            self.entry2]

    def test_consecutive(self, haystack):
        assert list(match_anywhere(['foo', 'bar'], haystack)) \
            == [self.entry1, self.entry2]
        assert list(match_anywhere(['bar', 'foo'], haystack)) == []

    def test_skip(self, haystack):
        assert list(match_anywhere(['baz', 'bar'], haystack)) == [self.entry2]
        assert list(match_anywhere(['中', '国'], haystack)) == [self.entry4]

    def test_ignore_case(self, haystack):
        assert list(match_anywhere(['bAz', 'bAR'], haystack, ignore_case=True)) \
            == [self.entry2]

    def test_backslashes_for_windows_paths(self, windows_haystack):
        # https://github.com/wting/autojump/issues/281
        assert list(match_anywhere(['foo', 'baz'], windows_haystack)) \
            == [self.win_entry1]
        assert list(match_anywhere(['program', 'gimp'], windows_haystack, True)) \
            == [self.win_entry2]
        assert list(match_anywhere(['win', '32'], windows_haystack, True)) \
            == [self.win_entry3]

    def test_wildcard_in_needle(self, haystack):
        # https://github.com/wting/autojump/issues/402
        assert list(match_anywhere(['*', 'this'], haystack)) == []
        assert list(match_anywhere(['this', '*'], haystack)) == [self.entry5]
