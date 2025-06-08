group "default" {
  targets = ["dev", "prd"]
}

variable "REL" {
  default = "bookworm"
}

variable "DOCKER_IMAGE_NAME" {
  default = "zebby76/frankenphp"
}

variable "DOCKER_IMAGE_VERSION" {
  default = "snapshot"
}

variable "DOCKER_IMAGE_LATEST" {
  default = false
}

variable "GIT_HASH" {}

variable "PHP_VERSION" {
  default = "8.4"
}

variable "FRANKENPHP_VERSION" {
  default = "1.6.0"
}

variable "NODE_VERSION" {
  default = "20"
}

variable "COMPOSER_VERSION" {
  default = "2.8.4"
}

variable "PHP_EXT_REDIS_VERSION" {
  default = "6.2.0"
}

variable "PHP_EXT_APCU_VERSION" {
  default = "5.1.24"
}

variable "PHP_EXT_XDEBUG_VERSION" {
  default = "3.4.2"
}

variable "GOMPLATE_VERSION" {
  default = "4.3.2"
}

variable "AWSCLI_VERSION" {
  default = "2.27.30"
}

variable "AWSCLI_ARCH" {
  default = "x86_64"
}

function "tag" {
  params = [version, tgt]
  result = [
    version == "" ? "" : "${DOCKER_IMAGE_NAME}:${trimprefix("${version}${tgt == "dev" ? "-dev" : ""}", "latest-")}",
  ]
}

# cleanTag ensures that the tag is a valid Docker tag
# see https://github.com/distribution/distribution/blob/v2.8.2/reference/regexp.go#L37
function "clean_tag" {
  params = [tag]
  result = substr(regex_replace(regex_replace(tag, "[^\\w.-]", "-"), "^([^\\w])", "r$0"), 0, 127)
}

# semver adds semver-compliant tag if a semver version number is passed, or returns the revision itself
# see https://semver.org/#is-there-a-suggested-regular-expression-regex-to-check-a-semver-string
function "semver" {
  params = [rev]
  result = __semver(_semver(regexall("^v?(?P<major>0|[1-9]\\d*)\\.(?P<minor>0|[1-9]\\d*)\\.(?P<patch>0|[1-9]\\d*)(?:-(?P<prerelease>(?:0|[1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\\.(?:0|[1-9]\\d*|\\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\\+(?P<buildmetadata>[0-9a-zA-Z-]+(?:\\.[0-9a-zA-Z-]+)*))?$", rev)))
}

function "_semver" {
    params = [matches]
    result = length(matches) == 0 ? {} : matches[0]
}

function "__semver" {
    params = [v]
    result = v == {} ? [clean_tag(DOCKER_IMAGE_VERSION)] : v.prerelease == null ? [v.major, "${v.major}.${v.minor}", "${v.major}.${v.minor}.${v.patch}"] : ["${v.major}.${v.minor}.${v.patch}-${v.prerelease}"]
}

target "default" {
  name = "${tgt}"

  matrix = {
    tgt = ["prd", "dev"]
  }

  context    = "."
  dockerfile = "Dockerfile"
  target     = tgt

  platforms  = [
    "linux/amd64",
    "linux/arm64"
  ]

  args = {
    REL_ARG                    = "${REL}"
    PHP_VERSION_ARG            = "${PHP_VERSION}"
    NODE_VERSION_ARG           = "${NODE_VERSION}"
    COMPOSER_VERSION_ARG       = "${COMPOSER_VERSION}"
    FRANKENPHP_VERSION_ARG     = "${FRANKENPHP_VERSION}"
    PHP_EXT_REDIS_VERSION_ARG  = "${PHP_EXT_REDIS_VERSION}"
    PHP_EXT_APCU_VERSION_ARG   = "${PHP_EXT_APCU_VERSION}"
    PHP_EXT_XDEBUG_VERSION_ARG = "${PHP_EXT_XDEBUG_VERSION}"
    GOMPLATE_VERSION_ARG       = "${GOMPLATE_VERSION}"
    AWSCLI_VERSION_ARG         = "${AWSCLI_VERSION}"
    AWSCLI_ARCH_ARG            = "${AWSCLI_ARCH}"
  }

  labels = {
    "org.opencontainers.image.created" = "${timestamp()}"
    "org.opencontainers.image.version" = FRANKENPHP_VERSION
    "org.opencontainers.image.revision" = GIT_HASH
  }

  tags = distinct(flatten([
      DOCKER_IMAGE_LATEST ? tag("latest", tgt) : [],
      tag(GIT_HASH == "" || DOCKER_IMAGE_VERSION != "snapshot" ? "" : "sha-${substr(GIT_HASH, 0, 7)}", tgt),
      DOCKER_IMAGE_VERSION == "snapshot" ? [tag("snapshot", tgt)] : [for v in semver(DOCKER_IMAGE_VERSION) : tag(v, tgt)]
    ])
  )

  hooks = [
    {
      platform = "linux/amd64"
      build_args = {
        AWSCLI_ARCH_ARG = "x86_64"
      }
    },     
    {
      platform = "linux/arm64"
      build_args = {
        AWSCLI_ARCH_ARG = "aarch64"
      }
    }
  ]

  attest = [
    {
      type = "provenance"
      mode = "max"
    },
    {
      type = "sbom"
    }
  ]

}