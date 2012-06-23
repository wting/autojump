#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
    Tests autojump.
"""

from __future__ import division
import autojump
import contextlib
import random
import os
import shutil
import sys
import tempfile
import unittest

@contextlib.contextmanager
def no_stderr():
    savestderr = sys.stderr
    class DevNull(object):
        def write(self, _): pass
    sys.stderr = DevNull()
    yield
    sys.stderr = savestderr

# test suite
class TestAutojump(unittest.TestCase):

    def setUp(self):
        autojump.CONFIG_DIR = tempfile.mkdtemp()
        autojump.TESTING = True
        self.fd, self.fname = tempfile.mkstemp()
        self.db = autojump.Database(self.fname)

        random.seed()

    def tearDown(self):
        os.remove(self.fname)
        if os.path.isfile(self.fname + ".bak"):
            os.remove(self.fname + ".bak")
        if (os.path.exists(autojump.CONFIG_DIR) and
            ('tmp' in autojump.CONFIG_DIR or 'temp' in autojump.CONFIG_DIR)):
            shutil.rmtree(autojump.CONFIG_DIR)

    def test_config(self):
        self.assertEqual(autojump.COMPLETION_SEPARATOR, '__')

    def test_db_add(self):
        self.db.add('/1', 100)
        self.assertEqual(self.db.get_weight('/1'), 100)
        self.db.add('/2', 10)
        self.assertEqual(self.db.get_weight('/2'), 10)
        self.db.add('/2', 10)
        self.assertEqual(self.db.get_weight('/2'), 14.142135623730951)

    def test_db_get_weight(self):
        self.assertEqual(self.db.get_weight('/'), 0)

    def test_db_decay(self):
        self.db.add('/1', 10)
        self.db.decay()
        self.assertTrue(self.db.get_weight('/1') < 10)

    def test_db_load_existing(self):
        self.db = autojump.Database('tests/database.txt')
        self.assertTrue(len(self.db) > 0)

    def test_db_load_empty(self):
        # setup
        _, fname = tempfile.mkstemp()
        db = autojump.Database(fname)

        try:
            # test
            self.assertEquals(len(self.db), 0)
        finally:
            # teardown
            os.remove(fname)

    def test_db_load_backup(self):
        # setup
        fname = '/tmp/autojump_test_db_load_backup_' + str(random.randint(0,32678))
        db = autojump.Database(fname)
        db.add('/1')
        os.rename(fname, fname + '.bak')

        try:
            # test
            with no_stderr():
                db = autojump.Database(fname)
            self.assertTrue(len(db.data) > 0)
            self.assertTrue(os.path.isfile(fname))
        finally:
            # teardown
            os.remove(fname)
            os.remove(fname + '.bak')

    def test_db_purge(self):
        self.db.add('/1')
        self.db.purge()
        self.assertEquals(len(self.db), 0)

    def test_db_save(self):
        # setup
        fname = '/tmp/autojump_test_db_save_' + str(random.randint(0,32678)) + '.txt'
        db = autojump.Database(fname)

        try:
            # test
            db.save()
            self.assertTrue(os.path.isfile(fname))
        finally:
            # teardown
            os.remove(fname)
            os.remove(fname + '.bak')

    def test_db_trim(self):
        self.db.add('/1')
        self.db.add('/2')
        self.db.add('/3')
        self.db.add('/4')
        self.db.add('/5')
        self.db.add('/6')
        self.db.add('/7')
        self.db.add('/8')
        self.db.add('/9')
        self.db.add('/10')
        self.assertEquals(len(self.db), 10)
        self.db.trim()
        self.assertEquals(len(self.db), 9)

    def test_db_decode(self):
        #FIXME
        self.assertEquals(autojump.decode('foo'), 'foo')

    def test_db_unico(self):
        #FIXME
        self.assertEquals(autojump.unico('foo'), u'foo')

    def test_match_normal(self):
        max_matches = 1
        self.db.add('/foo', 10)
        self.db.add('/foo/bar', 20)

        patterns = [u'']
        results = autojump.find_matches(self.db, patterns, max_matches)
        self.assertEquals(results[0], '/foo/bar')

        patterns = [u'random']
        results = autojump.find_matches(self.db, patterns, max_matches)
        self.assertTrue(len(results) == 0)

        patterns = [u'fo']
        results = autojump.find_matches(self.db, patterns, max_matches)
        self.assertEquals(results[0], '/foo')

        self.db.add('/foo/bat', 15)
        patterns = [u'ba']
        results = autojump.find_matches(self.db, patterns, max_matches)
        self.assertEquals(results[0], '/foo/bar')

        self.db.add('/code/inbox', 5)
        self.db.add('/home/user/inbox', 10)
        patterns = [u'inbox']
        results = autojump.find_matches(self.db, patterns, max_matches)
        self.assertEquals(results[0], '/home/user/inbox')
        patterns = [u'co', u'in']
        results = autojump.find_matches(self.db, patterns, max_matches)
        self.assertEquals(results[0], '/code/inbox')

    def test_match_completion(self):
        max_matches = 9
        ignore_case = True
        self.db.add('/1')
        self.db.add('/2')
        self.db.add('/3')
        self.db.add('/4')
        self.db.add('/5', 20)
        self.db.add('/6', 15)
        self.db.add('/7')
        self.db.add('/8')
        self.db.add('/9')

        patterns = [u'']
        results = autojump.find_matches(self.db, patterns, max_matches, ignore_case)
        self.assertEquals(results, ['/5', '/6', '/9', '/8', '/7', '/4', '/3', '/2', '/1'])

    def test_match_case_insensitive(self):
        max_matches = 1
        ignore_case = True
        self.db.add('/FOO', 20)
        self.db.add('/foo', 10)

        patterns = [u'fo']
        results = autojump.find_matches(self.db, patterns, max_matches, ignore_case)
        self.assertEquals(results[0], '/FOO')

    def test_match_fuzzy(self):
        max_matches = 1
        ignore_case = True
        fuzzy_search = True
        self.db.add('/foo', 10)
        self.db.add('/foo/bar', 20)
        self.db.add('/abcdefg', 10)

        patterns = [u'random']
        results = autojump.find_matches(self.db, patterns, max_matches, ignore_case, fuzzy_search)
        self.assertTrue(len(results) == 0)

        patterns = [u'abcdefg']
        results = autojump.find_matches(self.db, patterns, max_matches, ignore_case, fuzzy_search)
        self.assertEquals(results[0], '/abcdefg')

        patterns = [u'abcefg']
        results = autojump.find_matches(self.db, patterns, max_matches, ignore_case, fuzzy_search)
        self.assertEquals(results[0], '/abcdefg')

        patterns = [u'bacef']
        results = autojump.find_matches(self.db, patterns, max_matches, ignore_case, fuzzy_search)
        self.assertEquals(results[0], '/abcdefg')

if __name__ == '__main__':
    unittest.main()
