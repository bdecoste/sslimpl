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
    _openssl()
    _com_google_absl()

def _openssl():
    native.bind(
        name = "ssl",
        actual = "@openssl//:openssl-lib",
)

def _com_google_absl():
    _repository_impl("com_google_absl")
    native.bind(
        name = "abseil_any",
        actual = "@com_google_absl//absl/types:any",
    )
    native.bind(
        name = "abseil_base",
        actual = "@com_google_absl//absl/base:base",
    )
    native.bind(
        name = "abseil_flat_hash_map",
        actual = "@com_google_absl//absl/container:flat_hash_map",
    )
    native.bind(
        name = "abseil_flat_hash_set",
        actual = "@com_google_absl//absl/container:flat_hash_set",
    )
    native.bind(
        name = "abseil_strings",
        actual = "@com_google_absl//absl/strings:strings",
    )
    native.bind(
        name = "abseil_int128",
        actual = "@com_google_absl//absl/numeric:int128",
    )
    native.bind(
        name = "abseil_optional",
        actual = "@com_google_absl//absl/types:optional",
    )
    native.bind(
        name = "abseil_synchronization",
        actual = "@com_google_absl//absl/synchronization:synchronization",
    )
    native.bind(
        name = "abseil_symbolize",
        actual = "@com_google_absl//absl/debugging:symbolize",
    )

    # Require abseil_time as an indirect dependency as it is needed by the
    # direct dependency jwt_verify_lib.
    native.bind(
        name = "abseil_time",
        actual = "@com_google_absl//absl/time:time",
    )
