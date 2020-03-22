PLATFORMS = linux/amd64,linux/arm64,linux/arm/v6,linux/arm/v7,linux/i386
VERSION = $(shell cat VERSION)
WEBPROC_VERSION=0.3.3
BINFMT = a7996909642ee92942dcd6cff44b9b95f08dad64
#DOCKER_USER = test
#DOCKER_PASS = test
ifeq ($(REPO),)
  REPO = dnsmasq
endif
ifeq ($(CIRCLE_TAG),)
	TAG = latest
else
	TAG = $(CIRCLE_TAG)
endif

.PHONY: all init build clean

all: init build clean

init: clean
	@docker run --rm --privileged docker/binfmt:$(BINFMT)
	@docker buildx create --name dnsmasq_builder
	@docker buildx use dnsmasq_builder
	@docker buildx inspect --bootstrap

build:
	@docker login -u $(DOCKER_USER) -p $(DOCKER_PASS)
	@docker buildx build \
			--build-arg BUILD_DATE=$(shell date -u +"%Y-%m-%dT%H:%M:%SZ") \
			--build-arg VCS_REF=$(shell git rev-parse --short HEAD) \
			--build-arg VCS_URL=$(shell git config --get remote.origin.url) \
			--build-arg WEBPROC_VERSION=$(WEBPROC_VERSION) \
			--build-arg VERSION=$(VERSION) \
			--platform $(PLATFORMS) \
			--push \
			-t $(REPO):$(TAG) .
	@docker logout

clean:
	@docker buildx rm dnsmasq_builder | true
