TARGETS := $(shell ls scripts)

$(TARGETS):
	./scripts/$@

.DEFAULT_GOAL := default

.PHONY: $(TARGETS)
