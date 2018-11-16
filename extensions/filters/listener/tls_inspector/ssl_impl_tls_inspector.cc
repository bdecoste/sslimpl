#include <algorithm>
#include <memory>
#include <string>
#include <vector>

#include "openssl/ssl.h"
#include "openssl/hmac.h"
#include "openssl/rand.h"
#include "openssl/x509v3.h"

#include "common/ssl/ssl_impl.h"

namespace Envoy {
namespace Ssl {

const SSL_METHOD *TLS_with_buffers_method(void) {
  return TLS_method();
}

} // namespace Ssl
} // namespace Envoy
