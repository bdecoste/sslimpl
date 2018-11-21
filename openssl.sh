set -x 

SOURCE_DIR=$1

/usr/bin/cp -f orig/bazel/repository_locations.bzl ${SOURCE_DIR}/bazel/repository_locations.bzl
/usr/bin/cp -f orig/bazel/repositories.bzl ${SOURCE_DIR}/bazel/repositories.bzl
/usr/bin/cp -f orig/common/ssl/BUILD ${SOURCE_DIR}/source/common/ssl/BUILD
/usr/bin/cp -f orig/extensions/filters/listener/tls_inspector/BUILD ${SOURCE_DIR}/source/extensions/filters/listener/tls_inspector/BUILD

function replace_text() {
  START=$(grep -nr "${DELETE_START_PATTERN}" ${SOURCE_DIR}/${FILE} | cut -d':' -f1)
  START=$((${START} + ${START_OFFSET}))
  if [[ ! -z "${DELETE_STOP_PATTERN}" ]]; then
    STOP=$(tail --lines=+${START}  ${SOURCE_DIR}/${FILE} | grep -nr ${DELETE_STOP_PATTERN} - |  cut -d':' -f1 | head -1)
    CUT=$((${START} + ${STOP} - 1))
  else
    CUT=$((${START} + 1))
  fi
  CUT_TEXT=$(sed -n "${START},${CUT} p" ${SOURCE_DIR}/${FILE})
  sed -i "${START},${CUT} d" ${SOURCE_DIR}/${FILE}

  if [[ ! -z "${ADD_TEXT}" ]]; then
    ex -s -c "${START}i|${ADD_TEXT}" -c x ${SOURCE_DIR}/${FILE}
  fi
}

FILE="bazel/repository_locations.bzl"
DELETE_START_PATTERN="boringssl = dict("
DELETE_STOP_PATTERN="),"
START_OFFSET="0"
ADD_TEXT="# EXTERNAL OPENSSL
    sslimpl = dict(
        sha256 = "e5c627f0cf6e13ae11af2e08537d304d399d5b2e0823dc891a83fefe0e8127b8",
        strip_prefix = "sslimpl-a98c18a31a08150ea545089306a96d9fa6941fc8",
        urls = ["https://github.com/bdecoste/sslimpl/archive/a98c18a31a08150ea545089306a96d9fa6941fc8.tar.gz"],
    ),"
replace_text

FILE="bazel/repositories.bzl"
DELETE_START_PATTERN="def _boringssl():"
DELETE_STOP_PATTERN=" )"
START_OFFSET="0"
ADD_TEXT="# EXTERNAL OPENSSL
def _openssl():
    native.bind(
        name = "ssl",
        actual = "@openssl//:openssl-lib",
)

# EXTERNAL OPENSSL
def _bssl_wrapper():
    _repository_impl("bssl_wrapper")
    native.bind(
        name = "bssl_wrapper_lib",
        actual = "@bssl_wrapper//:bssl_wrapper",
    )

# EXTERNAL OPENSSL
def _sslimpl():
    _repository_impl("sslimpl")
    native.bind(
        name = "ssl_impl_common_lib",
        actual = "@sslimpl//common/ssl:ssl_impl_common_lib",
    )
    native.bind(
        name = "ssl_impl_hdrs_lib",
        actual = "@sslimpl//common/ssl:ssl_impl_hdrs_lib",
    )
    native.bind(
        name = "ssl_impl_tls_inspector_lib",
        actual = "@sslimpl//extensions/filters/listener/tls_inspector:ssl_impl_tls_inspector_lib",
    )"
replace_text

FILE="bazel/repositories.bzl"
DELETE_START_PATTERN="    _boringssl()"
DELETE_STOP_PATTERN=""
START_OFFSET="0"
ADD_TEXT="    # EXTERNAL OPENSSL
    _openssl()
    _sslimpl()
    _bssl_wrapper()"
replace_text

FILE="source/common/ssl/BUILD"
DELETE_START_PATTERN="name = \"ssl_impl_common_lib\","
DELETE_STOP_PATTERN=")"
START_OFFSET="-1"
ADD_TEXT=""
replace_text

FILE="source/common/ssl/BUILD"
DELETE_START_PATTERN="name = \"ssl_impl_hdrs_lib\","
DELETE_STOP_PATTERN=")"
START_OFFSET="-1"
ADD_TEXT=""
replace_text

sed -i "s/\":ssl_impl_common_lib\",//g" ${SOURCE_DIR}/source/common/ssl/BUILD
sed -i "s/\":ssl_impl_hdrs_lib\",//g" ${SOURCE_DIR}/source/common/ssl/BUILD

FILE="source/common/ssl/BUILD"
DELETE_START_PATTERN="\"context_manager_impl.h\","
DELETE_STOP_PATTERN=""
START_OFFSET="0"
ADD_TEXT="        \"context_manager_impl.h\",
    ],
    external_deps = [
                 \"ssl\",
# EXTERNAL OPENSSL
                \"ssl_impl_common_lib\",
                \"ssl_impl_hdrs_lib\","
replace_text

FILE="source/common/ssl/BUILD"
DELETE_START_PATTERN="\"utility.h\""
DELETE_STOP_PATTERN=""
START_OFFSET="0"
ADD_TEXT="         \"utility.h\",
    ],
    external_deps = [
        \"ssl\",
# EXTERNAL OPENSSL
        \"ssl_impl_hdrs_lib\","
replace_text

sed -i "s/\"//source/common/ssl:ssl_impl_hdrs_lib\",//g" ${SOURCE_DIR}/source/extensions/filters/listener/tls_inspector/BUILD

FILE="source/extensions/filters/listener/tls_inspector/BUILD"
DELETE_START_PATTERN="\"tls_inspector.h\""
DELETE_STOP_PATTERN=""
START_OFFSET="0"
ADD_TEXT="         \"tls_inspector.h\",
    ],
    external_deps = [
                 \"ssl\",
# EXTERNAL OPENSSL
              \"ssl_impl_hdrs_lib\",
              \"bssl_wrapper_lib\",
              \"ssl_impl_tls_inspector_lib\","
replace_text





