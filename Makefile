#!/usr/bin/make -f

ifneq (,$(wildcard ./.build.env))
    include .build.env
    export
endif

LIB = ./Dockerfiles
DOCKERFILE=Dockerfile.in

GIT_HASH ?= $(shell git log --format="%h" -n 1)
BUILD_DATE ?= $(shell date -u +'%Y-%m-%dT%H:%M:%SZ')

_BUILD_ARGS_TARGET ?= prd
_BUILD_ARGS_TAG ?= latest

CONTAINER_ENGINE ?= docker
CONTAINER_TARGET_IMAGE_FORMAT ?= docker

DOCKER_BUILDX_BUILDER_NAME ?= default
#DOCKER_BUILDX_BUILDER_NAME ?= cloud-zebby76-cloud-builder

.DEFAULT_GOAL := help
.PHONY: help build print Dockerfile

help: # Show help for each of the Makefile recipes.
	@grep -E '^[a-zA-Z0-9 -]+:.*#'  Makefile | sort | while read -r l; do printf "\033[1;32m$$(echo $$l | cut -f 1 -d':')\033[00m:$$(echo $$l | cut -f 2- -d'#')\n"; done

print: # Print the options without building
	docker buildx bake --print

build: # Build [prd,dev] variant Docker images
	@echo "Build [${DOCKER_IMAGE_NAME}:${_BUILD_ARGS_TAG}] Docker image ..."
	@$(MAKE) -s _dockerfile
    ifeq ($(CONTAINER_ENGINE),podman)
		@echo "Building $(CONTAINER_TARGET_IMAGE_FORMAT) image format with buildah"
#		@buildah bud --no-cache --pull-always --force-rm --squash \
#			--build-arg VERSION_ARG="${PHP_VERSION}" \
#			--build-arg RELEASE_ARG="${_BUILD_ARGS_TAG}" \
#			--build-arg BUILD_DATE_ARG="${BUILD_DATE}" \
#			--build-arg VCS_REF_ARG="${GIT_HASH}" \
#			--build-arg NODE_VERSION_ARG=${NODE_VERSION} \
#			--build-arg COMPOSER_VERSION_ARG=${COMPOSER_VERSION} \
#			--build-arg AWS_CLI_VERSION_ARG=${AWS_CLI_VERSION} \
#			--build-arg PHP_EXT_REDIS_VERSION_ARG=${PHP_EXT_REDIS_VERSION} \
#			--build-arg PHP_EXT_APCU_VERSION_ARG=${PHP_EXT_APCU_VERSION} \
#			--build-arg PHP_EXT_XDEBUG_VERSION_ARG=${PHP_EXT_XDEBUG_VERSION} \
#			--format ${CONTAINER_TARGET_IMAGE_FORMAT} \
#			--target ${_BUILD_ARGS_TARGET} \
#			--tag ${DOCKER_IMAGE_NAME}:${_BUILD_ARGS_TAG} .
    else
		@echo "Building $(CONTAINER_TARGET_IMAGE_FORMAT) image format with docker"
		@if [ "$(DOCKER_BUILDX_BUILDER_NAME)" = "default" ]; then \
			echo "Using default builder → disable --push" ; \
			docker buildx bake --builder $(DOCKER_BUILDX_BUILDER_NAME) ; \
		else \
			echo "Using builder: $(DOCKER_BUILDX_BUILDER_NAME) (cloud or custom)" ; \
			docker buildx bake --push --builder $(DOCKER_BUILDX_BUILDER_NAME) ; \
		fi
    endif

cmd-exists-%:
	@hash $(*) > /dev/null 2>&1 || \
		(echo "ERROR: '$(*)' must be installed and available on your PATH."; exit 1)

Dockerfile: # generate Dockerfile
	@$(MAKE) -s _dockerfile

_dockerfile: $(LIB)/*.m4
	sed -e 's/# include(\(.*\))/include(\1)/g' $(LIB)/$(DOCKERFILE) | m4 -I $(LIB) > $(DOCKERFILE:.in=)