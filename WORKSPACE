workspace(name = "sslimpl")

load("//:repositories.bzl", "envoy_dependencies")

envoy_dependencies()

http_archive(
    name = "bssl_wrapper",
    sha256 = "265ae86648d29c29a6066aa1d464d828785bfc264bb3f0587f33216e94ebf94b",
    strip_prefix = "bssl_wrapper-31706514083664e39cbdcaadae2e4fff2b18f96d",
    url = "https://github.com/bdecoste/bssl_wrapper/archive/31706514083664e39cbdcaadae2e4fff2b18f96d.tar.gz",
)

new_local_repository(
    name = "openssl",
    path = "/usr/local/lib64",
    build_file = "openssl.BUILD"
)

