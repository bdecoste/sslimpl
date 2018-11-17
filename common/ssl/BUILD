licenses(["notice"])  # Apache 2

package(default_visibility = ["//visibility:public"])

cc_library(
    name = "ssl_impl_context_lib",
    srcs = ["ssl_impl_context.cc"],
    deps = [
        ":ssl_impl_lib",
        "//external:ssl",
        "@bssl_wrapper//:bssl_wrapper",
    ],
)

cc_library(
    name = "ssl_impl_lib",
    hdrs = ["ssl_impl.h"],
    deps = [
        "//external:ssl",
        "@bssl_wrapper//:bssl_wrapper",
    ],
)

