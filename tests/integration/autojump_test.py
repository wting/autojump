#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import os
import sys

sys.path.append(os.path.join(os.getcwd(), 'bin'))  # noqa
from autojump import find_matches
from autojump_data import entriefy


def test_find_matches_returns_unique_results(tmpdir):
    path = str(tmpdir)
    needle = str(os.path.basename(tmpdir))

    matches = find_matches(entriefy({path: 10}), [needle])

    assert list(matches) == list(entriefy({path: 10}))
