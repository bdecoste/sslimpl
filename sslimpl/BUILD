licenses(["notice"])  # Apache 2

package(default_visibility = ["//visibility:public"])

cc_library(
    name = "ssl_impl_context_lib",
    srcs = ["ssl_impl_context.cc"],
#    hdrs = ["ssl_impl_context.h"],
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

