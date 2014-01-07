#!/usr/bin/env python
# -*- coding: utf-8 -*-
from random import randrange
from shutil import rmtree
from tempfile import gettempdir
from tempfile import mkdtemp
import os
import sys

import mock
from testify import TestCase
from testify import assert_equal
from testify import assert_false
from testify import assert_raises
from testify import assert_true
from testify import class_setup
from testify import class_teardown
from testify import run
from testify import setup
from testify import suite
from testify import teardown

import autojump_utils
from autojump_utils import create_dir
from autojump_utils import encode_local
from autojump_utils import first
from autojump_utils import get_pwd
from autojump_utils import get_tab_entry_info
from autojump_utils import has_uppercase
from autojump_utils import in_bash
from autojump_utils import last
from autojump_utils import move_file
from autojump_utils import sanitize
from autojump_utils import second
from autojump_utils import surround_quotes
from autojump_utils import take
from autojump_utils import unico


class StringUnitTests(TestCase):
    @mock.patch.object(sys, 'getfilesystemencoding', return_value='ascii')
    def test_encode_local_ascii(self, _):
        assert_equal(encode_local(u'foo'), b'foo')

    @suite('disabled', reason='#246')
    def test_encode_local_ascii_fails(self):
        with assert_raises(UnicodeDecodeError):
            with mock.patch.object(
                    sys,
                    'getfilesystemencoding',
                    return_value='ascii'):
                encode_local(u'日本語')

    @mock.patch.object(sys, 'getfilesystemencoding', return_value=None)
    def test_encode_local_empty(self, _):
        assert_equal(encode_local(b'foo'), u'foo')

    @mock.patch.object(sys, 'getfilesystemencoding', return_value='utf-8')
    def test_encode_local_unicode(self, _):
        assert_equal(encode_local(b'foo'), u'foo')
        assert_equal(encode_local(u'foo'), u'foo')

    def test_has_uppercase(self):
        assert_true(has_uppercase('Foo'))
        assert_true(has_uppercase('foO'))
        assert_false(has_uppercase('foo'))
        assert_false(has_uppercase(''))

    @mock.patch.object(autojump_utils, 'in_bash', return_value=True)
    def test_surround_quotes_in_bash(self, _):
        assert_equal(surround_quotes('foo'), '"foo"')

    @mock.patch.object(autojump_utils, 'in_bash', return_value=False)
    def test_dont_surround_quotes_not_in_bash(self, _):
        assert_equal(surround_quotes('foo'), 'foo')

    def test_sanitize(self):
        assert_equal(sanitize([]), [])
        assert_equal(sanitize([r'/foo/bar/', r'/']), [u'/foo/bar', u'/'])

    def test_unico(self):
        assert_equal(unico(b'blah'), u'blah')
        assert_equal(unico(b'日本語'), u'日本語')
        assert_equal(unico(u'でもおれは中国人だ。'), u'でもおれは中国人だ。')


class IterationUnitTests(TestCase):
    def test_first(self):
        assert_equal(first(xrange(5)), 0)
        assert_equal(first([]), None)

    def test_second(self):
        assert_equal(second(xrange(5)), 1)
        assert_equal(second([]), None)

    def test_last(self):
        assert_equal(last(xrange(4)), 3)
        assert_equal(last([]), None)

    def test_take(self):
        assert_equal(list(take(1, xrange(3))), [0])
        assert_equal(list(take(2, xrange(3))), [0, 1])
        assert_equal(list(take(4, xrange(3))), [0, 1, 2])
        assert_equal(list(take(10, [])), [])


class EnvironmentalVariableIntegrationTests(TestCase):
    @setup
    def create_tmp_dir(self):
        self.tmp_dir = mkdtemp()

    @teardown
    def delete_tmp_dir(self):
        try:
            rmtree(self.tmp_dir)
        except OSError:
            pass

    def test_in_bash(self):
        os.environ['SHELL'] = '/bin/bash'
        assert_true(in_bash())
        os.environ['SHELL'] = '/usr/bin/zsh'
        assert_false(in_bash())

    def test_good_get_pwd(self):
        os.chdir(self.tmp_dir)
        assert_equal(get_pwd(), self.tmp_dir)

    def test_bad_get_pwd(self):
        os.chdir(self.tmp_dir)
        rmtree(self.tmp_dir)
        assert_raises(OSError, get_pwd)


class FileSystemIntegrationTests(TestCase):
    @class_setup
    def init(self):
        self.tmp_dir = os.path.join(gettempdir(), 'autojump')
        os.makedirs(self.tmp_dir)

    @class_teardown
    def cleanup(self):
        try:
            rmtree(self.tmp_dir)
        except OSError:
            pass

    def get_random_path(self):
        path = gettempdir()

        while os.path.exists(path):
            random_string = '%30x' % randrange(16 ** 30)
            path = os.path.join(self.tmp_dir, random_string)

        return path

    def get_random_file(self):
        path = self.get_random_path()
        with open(path, 'w+') as f:
            f.write('filler\n')

        return path

    def test_create_dir(self):
        path = self.get_random_path()
        create_dir(path)
        assert_true(os.path.exists(path))

        # should not raise OSError if directory already exists
        create_dir(path)
        assert_true(os.path.exists(path))

    def test_move_file(self):
        src = self.get_random_file()
        dst = self.get_random_path()
        assert_true(os.path.exists(src))
        assert_false(os.path.exists(dst))
        move_file(src, dst)
        assert_false(os.path.exists(src))
        assert_true(os.path.exists(dst))


class HelperFunctionsUnitTests(TestCase):
    def test_get_needle(self):
        assert_equal(
                get_tab_entry_info('foo__', '__'),
                ('foo', None, None))

    def test_get_index(self):
        assert_equal(
                get_tab_entry_info('foo__2', '__'),
                ('foo', 2, None))

    def test_get_path(self):
        assert_equal(
                get_tab_entry_info('foo__3__/foo/bar', '__'),
                ('foo', 3, '/foo/bar'))

    def test_get_none(self):
        assert_equal(
                get_tab_entry_info('gibberish content', '__'),
                (None, None, None))


if __name__ == "__main__":
    run()
