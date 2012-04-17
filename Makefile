VERSION = v20
TAGNAME = release-$(VERSION)

.PHONY: docs install

install:
	install.sh

docs:
	pandoc -s -w man docs/manpage.md -o docs/autojump.1
	pandoc -s -w markdown docs/manpage.md docs/install.md -o README.md

release:
	# Check for tag existence
	# git describe release-$(VERSION) 2>&1 >/dev/null || exit 1

	tools/git-version.sh $(TAGNAME)

	# Commit the version change
	git commit -m "version numbering" autojump

	# Create tag
	git tag -a $(TAGNAME)

	git archive --format=tar --prefix autojump_$(VERSION)/ $(TAGNAME) | gzip > autojump_$(VERSION).tar.gz
