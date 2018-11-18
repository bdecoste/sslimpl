licenses(["notice"])  # Apache 2

package(default_visibility = ["//visibility:public"])

cc_library(
    name = "ssl_impl_common_lib",
    srcs = ["ssl_impl_common.cc"],
    deps = [
        ":ssl_impl_hdrs_lib",
        "//external:ssl",
        "@bssl_wrapper//:bssl_wrapper",
    ],
)

cc_library(
    name = "ssl_impl_hdrs_lib",
    hdrs = ["ssl_impl.h"],
    deps = [
        "//external:ssl",
        "@bssl_wrapper//:bssl_wrapper",
    ],
)

