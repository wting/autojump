import os
import sys

sys.path.append(os.path.join(os.getcwd(), 'bin'))
from autojump_data import (
    entriefy,
    dictify,
    parse_data,
    Entry,
)


def test_entriefy():
    assert list(entriefy({})) == []
    data = {
        "path1": 10,
        "path2": 12
    }
    r = entriefy(data)
    assert set(r) == set([Entry("path1", 10), Entry("path2", 12)])


def test_dictify():
    assert dictify([]) == {}
    entries = [Entry("path1", 10), Entry("path2", 12)]
    assert dictify(entries) == {
        "path1": 10,
        "path2": 12
    }


class TestParseData:

    def test_valid_data_should_be_parsed(self):
        data = [
            "10.0\tpath_a",
            "12.3\tpath_a/path_b"
        ]
        assert parse_data(data) == {
            "path_a": 10.0,
            "path_a/path_b": 12.3
        }

    def test_invalid_data_should_be_ignored(self):
        data = [
            "10.0\tpath_a\tnada",
            "12.3",
            "10.0\tpath_a",
        ]
        assert parse_data(data) == {
            "path_a": 10.0
        }
