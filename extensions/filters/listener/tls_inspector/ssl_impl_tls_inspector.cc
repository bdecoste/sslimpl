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

void set_certificate_cb(SSL_CTX *ctx ){
  auto cert_cb = [](SSL *ssl, void *arg) -> int
  {
    return 0;
  };
  SSL_CTX_set_cert_cb(ctx, cert_cb, ctx);
}

} // namespace Ssl
} // namespace Envoy
