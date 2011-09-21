.PHONY: release

autojump: autojump.py
	./git-version.sh

version=`git describe $$(git rev-list --tags --max-count=1)`
number=`git describe $$(git rev-list --tags --max-count=1) | sed "s/^[a-z]*-//"`
release:
	@echo NOTE: make sure you\'re on a tagged commit
	git archive --format=tar --prefix autojump_$(number)/ $(version) | gzip > autojump_$(number).tar.gz


