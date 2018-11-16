licenses(["notice"])  # Apache 2

package(default_visibility = ["//visibility:public"])

cc_library(
    name = "context_lib",
    srcs = ["context.cc"],
    hdrs = ["context.h"],
    deps = [
        "//external:ssl",
    ],
)

cc_library(
    name = "ssl_impl_lib",
    hdrs = ["ssl_impl.h"],
    deps = [
        "//external:ssl",
    ],
)

