licenses(["notice"])  # Apache 2

package(default_visibility = ["//visibility:public"])

cc_library(
    name = "ssl_impl_tls_inspector_lib",
    srcs = ["ssl_impl_tls_inspector.cc"],
    deps = [
        "//common/ssl:ssl_impl_lib",
        "//external:ssl",
        "@bssl_wrapper//:bssl_wrapper",
    ],
)


