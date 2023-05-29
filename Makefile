include parse_pkgbuild.mk

.SUFFIXES:

# TODO: Refactor this to a simpler form.
MAKE_DEPENDS := $$(cat $(wildcard */PKGBUILD) | grep makedepends | grep -oE '[0-9a-zA-Z_-]+' | grep -v makedepends | paste -d ' ' -s -)

# Check if docker exists, and build with it unless requested not to.

ifneq ($(shell command -v docker),)
BUILD_WITH_CONTAINER ?= true
DOCKER_TAG := div72-pkgbuilds-builder
endif

ifeq ($(BUILD_WITH_CONTAINER),true)
RUN_COMMAND := docker run --rm -i --platform linux/amd64 -v $(PWD):/home/builder/PKGBUILDs -u builder -w /home/builder/PKGBUILDs $(DOCKER_TAG)
endif

PACKAGES := $(foreach pkg,$(wildcard */PKGBUILD),$(call pkgname,$(pkg))/$(call package_filename,$(pkg)))

print-%:
	@echo $($*)

default:
	@echo "Please specify a target. You can view buildable packages with make print-PACKAGES." && false

$(DOCKER_TAG).tar.gz: Dockerfile
	docker build -t $(DOCKER_TAG) .
	@echo "Saved Docker image tag as $(DOCKER_TAG)."
	#docker save $(DOCKER_TAG) | gzip > $(DOCKER_TAG).tar.gz

Dockerfile: Dockerfile.in $(wildcard */PKGBUILD)
	sed "s/{{make_depends}}/$(MAKE_DEPENDS)/g" < Dockerfile.in > Dockerfile

# FIXME: $(PACKAGES) is not properly evaluated for some reason?
#all: $(PACKAGES)
#	@:

.SECONDEXPANSION:
%.pkg.tar.zst: $$(dir %)/PKGBUILD $(DOCKER_TAG).tar.gz
	$(RUN_COMMAND) bash -c "cd $(dir $<) && makepkg -df"
