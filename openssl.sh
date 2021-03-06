set -x 

SOURCE_DIR=$1
TARGET=$2

/usr/bin/cp -f orig/bazel/repository_locations.bzl ${SOURCE_DIR}/bazel/repository_locations.bzl
/usr/bin/cp -f orig/bazel/repositories.bzl ${SOURCE_DIR}/bazel/repositories.bzl
/usr/bin/cp -f orig/source/common/ssl/build ${SOURCE_DIR}/source/common/ssl/BUILD
/usr/bin/cp -f orig/source/extensions/filters/listener/tls_inspector/build ${SOURCE_DIR}/source/extensions/filters/listener/tls_inspector/BUILD
/usr/bin/cp -f orig/test/common/ssl/build ${SOURCE_DIR}/test/common/ssl/BUILD
/usr/bin/cp -f orig/test/test_common/build ${SOURCE_DIR}/test/test_common/BUILD
/usr/bin/cp -f orig/WORKSPACE ${SOURCE_DIR}/WORKSPACE
/usr/bin/cp -f orig/tools/bazel.rc ${SOURCE_DIR}/tools/bazel.rc

if [ "$TARGET" == "CLEAN" ]; then
  exit
fi

BUILD_OPTIONS="
build --cxxopt -D_GLIBCXX_USE_CXX11_ABI=1
build --cxxopt -DENVOY_IGNORE_GLIBCXX_USE_CXX11_ABI_ERROR=1
"
echo "${BUILD_OPTIONS}" >> ${SOURCE_DIR}/tools/bazel.rc

if [ "$TARGET" == "BORINGSSL" ]; then
  exit
fi

function replace_text() {
  START=$(grep -nr "${DELETE_START_PATTERN}" ${SOURCE_DIR}/${FILE} | cut -d':' -f1)
  START=$((${START} + ${START_OFFSET}))
  if [[ ! -z "${DELETE_STOP_PATTERN}" ]]; then
    STOP=$(tail --lines=+${START}  ${SOURCE_DIR}/${FILE} | grep -nr "${DELETE_STOP_PATTERN}" - |  cut -d':' -f1 | head -1)
    CUT=$((${START} + ${STOP} - 1))
  else
    CUT=$((${START}))
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
        sha256 = \"dcc7cfb1453737877b4d1025b98fc35c2f10b2558dcf1aab92bb8332ebdd8cc0\",
        strip_prefix = \"sslimpl-bac47743e7852d2dfc5550ab23c689c487270f84\",
        urls = [\"https://github.com/bdecoste/sslimpl/archive/bac47743e7852d2dfc5550ab23c689c487270f84.tar.gz\"],
    ),
    # EXTERNAL OPENSSL
    bssl_wrapper = dict(
      sha256 = \"265ae86648d29c29a6066aa1d464d828785bfc264bb3f0587f33216e94ebf94b\",
      strip_prefix = \"bssl_wrapper-31706514083664e39cbdcaadae2e4fff2b18f96d\",
      urls = [\"https://github.com/bdecoste/bssl_wrapper/archive/31706514083664e39cbdcaadae2e4fff2b18f96d.tar.gz\"],
    ),"
replace_text

FILE="bazel/repository_locations.bzl"
DELETE_START_PATTERN="com_github_google_jwt_verify = dict("
DELETE_STOP_PATTERN="),"
START_OFFSET="0"
ADD_TEXT="    # EXTERNAL OPENSSL
    com_github_google_jwt_verify = dict(
        sha256 = \"bc7c176625b81eaa04b08e0e843b961970c3cb912b596dea40e24bfff091532b\",
        strip_prefix = \"jwt_verify_lib-89c042a33edd22d357d01bfbb422234f3f4f132e\",
        urls = [\"https://github.com/bdecoste/jwt_verify_lib/archive/89c042a33edd22d357d01bfbb422234f3f4f132e.tar.gz\"],
    ),"
replace_text

FILE="bazel/repositories.bzl"
DELETE_START_PATTERN="def _boringssl():"
DELETE_STOP_PATTERN=" )"
START_OFFSET="0"
ADD_TEXT="    # EXTERNAL OPENSSL
def _openssl():
    native.bind(
        name = \"ssl\",
        actual = \"@openssl//:openssl-lib\",
)

# EXTERNAL OPENSSL
def _bssl_wrapper():
    _repository_impl(\"bssl_wrapper\")
    native.bind(
        name = \"bssl_wrapper_lib\",
        actual = \"@bssl_wrapper//:bssl_wrapper\",
    )

# EXTERNAL OPENSSL
def _sslimpl():
    _repository_impl(\"sslimpl\")
    native.bind(
        name = \"ssl_impl_common_lib\",
        actual = \"@sslimpl//common/ssl:ssl_impl_common_lib\",
    )
    native.bind(
        name = \"ssl_impl_hdrs_lib\",
        actual = \"@sslimpl//common/ssl:ssl_impl_hdrs_lib\",
    )
    native.bind(
        name = \"ssl_impl_tls_inspector_lib\",
        actual = \"@sslimpl//extensions/filters/listener/tls_inspector:ssl_impl_tls_inspector_lib\",
    )"
replace_text

FILE="bazel/repositories.bzl"
DELETE_START_PATTERN="_boringssl()"
DELETE_STOP_PATTERN=""
START_OFFSET="0"
ADD_TEXT="
    # EXTERNAL OPENSSL
    _openssl()
    _sslimpl()
    _bssl_wrapper()

"
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
DELETE_START_PATTERN="\"context_manager_impl.h\""
DELETE_STOP_PATTERN="external_deps"
START_OFFSET="0"
ADD_TEXT="        \"context_manager_impl.h\",
    ],
    external_deps = [
                \"ssl\",
                # EXTERNAL OPENSSL
                \"ssl_impl_common_lib\",
                \"ssl_impl_hdrs_lib\",
    ],"
replace_text

FILE="source/common/ssl/BUILD"
DELETE_START_PATTERN="\"utility.h\""
DELETE_STOP_PATTERN="ssl"
START_OFFSET="0"
ADD_TEXT="    hdrs = [\"utility.h\"],
    external_deps = [
        \"ssl\",
        # EXTERNAL OPENSSL
        \"ssl_impl_hdrs_lib\",
        \"ssl_impl_common_lib\","
replace_text

sed -i "s|\"//source/common/ssl:ssl_impl_common_lib\",||g" ${SOURCE_DIR}/test/common/ssl/BUILD

FILE="test/common/ssl/BUILD"
DELETE_START_PATTERN="\"ssl_socket_test.cc\""
DELETE_STOP_PATTERN="\"ssl\""
START_OFFSET="0"
ADD_TEXT="        \"ssl_socket_test.cc\",
        \"ssl_certs_test.h\",
    ],
    data = [
        \"gen_unittest_certs.sh\",
        \"//test/common/ssl/test_data:certs\",
    ],
    external_deps = [
        \"ssl\",
        # EXTERNAL OPENSSL
        \"ssl_impl_hdrs_lib\",
        \"ssl_impl_common_lib\","
replace_text

sed -i "s|\"//source/common/ssl:ssl_impl_common_hdrs_lib\",||g" ${SOURCE_DIR}/test/test_common/BUILD
#sed -i "s|\"//source/extensions/filters/listener/tls_inspector:tls_inspector_lib\",||g" ${SOURCE_DIR}/test/test_common/BUILD

FILE="test/test_common/BUILD"
DELETE_START_PATTERN="\"tls_utility.h\""
DELETE_STOP_PATTERN="\"ssl\""
START_OFFSET="0"
ADD_TEXT="    hdrs = [\"tls_utility.h\"],
    external_deps = [
        \"ssl\",
        # EXTERNAL OPENSSL
        \"ssl_impl_hdrs_lib\",
        \"ssl_impl_tls_inspector_lib\","
replace_text

sed -i "s|\":ssl_impl_tls_inspector_lib\",||g" ${SOURCE_DIR}/source/extensions/filters/listener/tls_inspector/BUILD
sed -i "s|\"//source/common/ssl:ssl_impl_hdrs_lib\",||g" ${SOURCE_DIR}/source/extensions/filters/listener/tls_inspector/BUILD
sed -i "s|\"ssl_impl_tls_inspector.cc\",||g" ${SOURCE_DIR}/source/extensions/filters/listener/tls_inspector/BUILD

FILE="source/extensions/filters/listener/tls_inspector/BUILD"
DELETE_START_PATTERN="\"tls_inspector.h\","
DELETE_STOP_PATTERN="\"ssl\""
START_OFFSET="0"
ADD_TEXT="        \"tls_inspector.h\",
        \"ssl_impl_tls_inspector.h\",
    ],    
    external_deps = [
              \"ssl\",
              # EXTERNAL OPENSSL
              \"ssl_impl_hdrs_lib\",
              \"bssl_wrapper_lib\",
              \"ssl_impl_tls_inspector_lib\",
    ],"
replace_text

FILE="source/extensions/filters/listener/tls_inspector/BUILD"
DELETE_START_PATTERN="name = \"ssl_impl_tls_inspector_lib\","
DELETE_STOP_PATTERN=")"
START_OFFSET="-1"
ADD_TEXT=""
replace_text

OPENSSL_REPO="
new_local_repository(
    name = \"openssl\",
    path = \"/usr/local/lib64\",
    build_file = \"openssl.BUILD\"
)"
echo "${OPENSSL_REPO}" >> ${SOURCE_DIR}/WORKSPACE

BUILD_OPTIONS="
build --cxxopt -Wnon-virtual-dtor
build --cxxopt -Wformat
build --cxxopt -Wformat-security
build --cxxopt -Wno-error=old-style-cast
build --cxxopt -Wno-error=deprecated-declarations
build --cxxopt -w
build --cxxopt -ldl
"
echo "${BUILD_OPTIONS}" >> ${SOURCE_DIR}/tools/bazel.rc

cp openssl.BUILD ${SOURCE_DIR}






