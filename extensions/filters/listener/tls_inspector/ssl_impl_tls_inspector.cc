#include <algorithm>
#include <memory>
#include <string>
#include <vector>

#include "openssl/ssl.h"
#include "openssl/hmac.h"
#include "openssl/rand.h"
#include "openssl/x509v3.h"

#include "common/ssl/ssl_impl.h"

#include "absl/strings/string_view.h"

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

std::vector<absl::string_view> getAlpnProtocols(const unsigned char* data, unsigned int len) {
  std::vector<absl::string_view> protocols;
  absl::string_view str(reinterpret_cast<const char*>(data));
  for (int i = 0; i < len ; ){

    uint32_t protocol_length = 0;
    protocol_length <<= 8;
    protocol_length |= data[i];

    ++i;

    absl::string_view protocol(str.substr(i, protocol_length));
    protocols.push_back(protocol);

    i += protocol_length;
  }

  return protocols;
}


} // namespace Ssl
} // namespace Envoy
