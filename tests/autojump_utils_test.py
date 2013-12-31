#!/usr/bin/env python2
# -*- coding: utf-8 -*-
import mock
from testify import TestCase
from testify import assert_equal
from testify import run

import autojump_utils
from autojump_utils import decode
from autojump_utils import first
from autojump_utils import last
from autojump_utils import sanitize
from autojump_utils import second
from autojump_utils import surround_quotes
from autojump_utils import take


class StringTestCase(TestCase):
    def test_decode(self):
        assert_equal(decode(r'blah'), u'blah')
        assert_equal(decode(r'日本語'), u'日本語')

    @mock.patch.object(autojump_utils, 'in_bash', return_value=True)
    def test_surround_quotes_in_bash(self, _):
        assert_equal(surround_quotes('foo'), '"foo"')

    @mock.patch.object(autojump_utils, 'in_bash', return_value=False)
    def test_dont_surround_quotes_not_in_bash(self, _):
        assert_equal(surround_quotes('foo'), 'foo')

    def test_sanitize(self):
        assert_equal(sanitize([]), [])
        assert_equal(sanitize([r'/foo/bar/', r'/']), [u'/foo/bar', u'/'])


class IterationTestCase(TestCase):
    def test_first(self):
        assert_equal(first((0, 1)), 0)
        assert_equal(first(()), None)

    def test_second(self):
        assert_equal(second((0, 1)), 1)
        assert_equal(second((0,)), None)

    def test_last(self):
        assert_equal(last((1, 2, 3)), 3)
        assert_equal(last(()), None)

    def test_take(self):
        xs = [1, 2, 3]
        assert_equal(list(take(1, xs)), [1])
        assert_equal(list(take(2, xs)), [1, 2])
        assert_equal(list(take(4, xs)), [1, 2, 3])
        assert_equal(list(take(10, [])), [])


class EnvironmentalVariableTestCase(TestCase):
    pass


if __name__ == "__main__":
    run()
