load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load(":repository_locations.bzl", "REPOSITORY_LOCATIONS")

def _repository_impl(name, **kwargs):
    # `existing_rule_keys` contains the names of repositories that have already
    # been defined in the Bazel workspace. By skipping repos with existing keys,
    # users can override dependency versions by using standard Bazel repository
    # rules in their WORKSPACE files.
    existing_rule_keys = native.existing_rules().keys()
    if name in existing_rule_keys:
        # This repository has already been defined, probably because the user
        # wants to override the version. Do nothing.
        return

    loc_key = kwargs.pop("repository_key", name)
    location = REPOSITORY_LOCATIONS[loc_key]

    # Git tags are mutable. We want to depend on commit IDs instead. Give the
    # user a useful error if they accidentally specify a tag.
    if "tag" in location:
        fail(
            "Refusing to depend on Git tag %r for external dependency %r: use 'commit' instead." %
            (location["tag"], name),
        )

    # HTTP tarball at a given URL. Add a BUILD file if requested.
    http_archive(
        name = name,
        urls = location["urls"],
        sha256 = location["sha256"],
        strip_prefix = location.get("strip_prefix", ""),
        **kwargs
    )

def envoy_dependencies(path = "@envoy_deps//", skip_targets = []):
#    _boringssl()
    _openssl()

def _boringssl():
    _repository_impl("boringssl")
    native.bind(
        name = "ssl",
        actual = "@boringssl//:ssl",
    )

def _openssl():
    native.bind(
        name = "ssl",
        actual = "@openssl//:openssl-lib",
)
