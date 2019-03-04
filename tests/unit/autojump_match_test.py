#!/usr/bin/env python
# -*- coding: utf-8 -*-
import os
import sys
import platform

import pytest

sys.path.append(os.path.join(os.getcwd(), 'bin'))  # noqa
from autojump_data import Entry
from autojump_match import match_anywhere
from autojump_match import match_consecutive

is_windows = platform.system() == 'Windows'

class TestMatchAnywhere(object):

    entry1 = Entry('/foo/bar/baz', 10)
    entry2 = Entry('/baz/foo/bar', 10)
    entry3 = Entry('/foo/baz', 10)
    entry4 = Entry('/中/zhong/国/guo', 10)
    entry5 = Entry('/is\'t/this/a/b*tchin/edge/case?', 10)

    win_entry1 = Entry('C:\\foo\\bar\\baz', 10)
    win_entry2 = Entry('C:\\baz\\foo\\bar', 10)
    win_entry3 = Entry('C:\\foo\\baz', 10)
    win_entry4 = Entry('C:\\中\\zhong\\国\\guo', 10)
    win_entry5 = Entry('C:\\is\'t\\this\\a\\b*tchin\\edge\\case?', 10)

    @pytest.fixture
    def haystack(self):

        if platform.system() == 'Windows':
            return [
                self.win_entry1,
                self.win_entry2,
                self.win_entry3,
                self.win_entry4,
                self.win_entry5,
            ]
        else:
            return [
                self.entry1,
                self.entry2,
                self.entry3,
                self.entry4,
                self.entry5,
            ]

    def test_single_needle(self, haystack):
        assert list(match_anywhere(['bar'], haystack)) == [haystack[0], haystack[1]]

    def test_consecutive(self, haystack):
        assert list(match_anywhere(['foo', 'bar'], haystack)) \
            == [haystack[0], haystack[1]]
        assert list(match_anywhere(['bar', 'foo'], haystack)) == []

    def test_skip(self, haystack):
        assert list(match_anywhere(['baz', 'bar'], haystack)) == [haystack[1]]
        assert list(match_anywhere(['中', '国'], haystack)) == [haystack[3]]

    def test_ignore_case(self, haystack):
        assert list(match_anywhere(['bAz', 'bAR'], haystack, ignore_case=True)) \
            == [haystack[1]]

    def test_wildcard_in_needle(self, haystack):
        # https://github.com/wting/autojump/issues/402
        assert list(match_anywhere(['*', 'this'], haystack)) == []
        assert list(match_anywhere(['this', '*'], haystack)) == [haystack[4]]


class TestMatchConsecutive(object):

    entry1 = Entry('/foo/bar/baz', 10)
    entry2 = Entry('/baz/foo/bar', 10)
    entry3 = Entry('/foo/baz', 10)
    entry4 = Entry('/中/zhong/国/guo', 10)
    entry5 = Entry('/日/本', 10)
    entry6 = Entry('/is\'t/this/a/b*tchin/edge/case?', 10)

    win_entry1 = Entry('C:\\foo\\bar\\baz', 10)
    win_entry2 = Entry('C:\\baz\\foo\\bar', 10)
    win_entry3 = Entry('C:\\foo\\baz', 10)
    win_entry4 = Entry('C:\\中\\zhong\\国\\guo', 10)
    win_entry5 = Entry('C:\\日\\本', 10)
    win_entry6 = Entry('C:\\is\'t\\this\\a\\b*tchin\\edge\\case?', 10)

    @pytest.fixture
    def haystack(self):

        if platform.system() == 'Windows':
            return [
                self.win_entry1,
                self.win_entry2,
                self.win_entry3,
                self.win_entry4,
                self.win_entry5,
                self.win_entry6,
            ]
        else:
            return [
                self.entry1,
                self.entry2,
                self.entry3,
                self.entry4,
                self.entry5,
                self.entry6,
            ]

    def test_single_needle(self, haystack):
        assert list(match_consecutive(['baz'], haystack)) == [haystack[0], haystack[2]]
        assert list(match_consecutive(['本'], haystack)) == [haystack[4]]

    def test_consecutive(self, haystack):
        assert list(match_consecutive(['bar', 'baz'], haystack)) == [haystack[0]]
        assert list(match_consecutive(['foo', 'bar'], haystack)) == [haystack[1]]
        assert list(match_consecutive(['国', 'guo'], haystack)) == [haystack[3]]
        assert list(match_consecutive(['bar', 'foo'], haystack)) == []

    def test_ignore_case(self, haystack):
        assert list(match_consecutive(['FoO', 'bAR'], haystack, ignore_case=True)) \
            == [haystack[1]]

    def test_wildcard_in_needle(self, haystack):
        assert list(match_consecutive(['*', 'this'], haystack)) == []
        assert list(match_consecutive(['*', 'edge', 'case'], haystack)) == [haystack[5]]
