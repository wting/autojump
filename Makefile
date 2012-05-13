VERSION = v20
TAGNAME = release-$(VERSION)

.PHONY: docs install uninstall test

install:
	install.sh

uninstall:
	uninstall.sh

docs:
	pandoc -s -w man docs/manpage_header.md docs/header.md docs/body.md -o docs/autojump.1
	pandoc -s -w markdown docs/header.md docs/install.md docs/development.md docs/body.md -o README.md

release:
	# Check for tag existence
	# git describe release-$(VERSION) 2>&1 >/dev/null || exit 1

	# Modify autojump with version
	./tools/git-version.sh $(TAGNAME)

	# Commit the version change
	git commit -m "version numbering" ./bin/autojump

	# Create tag
	git tag -a $(TAGNAME)

	# Create tagged archive
	git archive --format=tar --prefix autojump_$(VERSION)/ $(TAGNAME) | gzip > autojump_$(VERSION).tar.gz

test:
	@tests/runtests.py
