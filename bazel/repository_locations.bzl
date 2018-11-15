REPOSITORY_LOCATIONS = dict(
    boringssl = dict(
        # Use commits from branch "chromium-stable-with-bazel"
        sha256 = "d1700e0455f5f918f8a85ff3ce6cd684d05c766200ba6bdb18c77d5dcadc05a1",
        strip_prefix = "boringssl-060e9a583976e73d1ea8b2bfe8b9cab33c62fa17",
        # chromium-70.0.3538.67
        urls = ["https://github.com/google/boringssl/archive/060e9a583976e73d1ea8b2bfe8b9cab33c62fa17.tar.gz"],
    ),
)
