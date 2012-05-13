#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
    Tests autojump.
"""

from __future__ import division
import autojump
import tempfile
import unittest

# test suite
class TestAutojump(unittest.TestCase):

    def setUp(self):
        autojump.config(True)
        self.fd, DB_FILE = tempfile.mkstemp()
        self.db = autojump.Database(DB_FILE)
        pass

    def tearDown(self):
        pass

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

    def test_db_load(self):
        self.db = autojump.Database('tests/database.txt')
        self.assertTrue(len(self.db) > 0)

    def test_db_purge(self):
        self.db.add('/1')
        self.db.purge()
        self.assertEquals(len(self.db), 0)

    def test_db_save(self):
        pass

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
