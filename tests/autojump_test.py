#!/usr/bin/env python
# encoding: utf-8

from __future__ import division
from __future__ import print_function

from collections import namedtuple
import mock
from pprint import pprint as pp
import sys
import unittest

from autojump import config_defaults
from autojump import decode
from autojump import is_python2
from autojump import output
from autojump import output_quotes
from autojump import parse_env_args
from autojump import parse_args
from autojump import unico

# TODO(ting|2013-07-06): skip certain tests depending on Python version

class TestDatabase(unittest.TestCase):

    def setUp(self):
        self.config = config_defaults()

    def test_add(self):
        pass

class TestConfig(unittest.TestCase):

    def setUp(self):
        self.config = config_defaults()

    def test_parse_env_args(self):
        pass

class TestUtilities(unittest.TestCase):

    PythonVersion = namedtuple('MockPythonVersion', 'major, minor, micro')

    @mock.patch.object(sys, 'version_info')
    def test_is_python2_passes_python2(self, mock_version):
        mock_version.__getitem__.side_effect = self.PythonVersion(2, 6, 7)
        self.assertTrue(is_python2())

        mock_version.__getitem__.side_effect = self.PythonVersion(2, 7, 3)
        self.assertTrue(is_python2())

    @mock.patch.object(sys, 'version_info')
    def test_is_python2_fails_python3(self, mock_version):
        mock_version.__getitem__.side_effect = self.PythonVersion(3, 2, 3)
        self.assertFalse(is_python2())

    @mock.patch.object(sys, 'version_info')
    def test_unico_converts_python2_string(self, mock_version):
        mock_version.__getitem__.side_effect = self.PythonVersion(2, 6, 7)
        self.assertEqual(unico('cookie monster'), u'cookie monster')

    @mock.patch.object(sys, 'version_info')
    @mock.patch.object(sys, 'getfilesystemencoding')
    def test_decode_converts_python2_string(self, mock_version, mock_encoding):
        mock_version.__getitem__.side_effect = self.PythonVersion(2, 6, 7)
        mock_encoding.return_value = 'UTF-8'
        self.assertEqual(decode('banana man'), u'banana man')

    def test_output_quotes(self):
        output = lambda x: x
        from pprint import pprint as pp; import ipdb; ipdb.set_trace()
        pp(self.config)
        self.config['args'].complete = False
        self.config['args'].bash = False
        normal = "foo"
        quotes = "'foo'"

        self.assertEqual(
                test_output_quotes(config, normal),
                normal)


if __name__ == "__main__":
    unittest.main()
