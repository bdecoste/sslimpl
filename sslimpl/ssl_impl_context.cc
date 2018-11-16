#include <algorithm>
#include <memory>
#include <string>
#include <vector>

#include "openssl/ssl.h"
#include "openssl/hmac.h"
#include "openssl/rand.h"
#include "openssl/x509v3.h"

namespace Envoy {
namespace Ssl {

int alpnSelectCallback(std::vector<uint8_t> parsed_alpn_protocols,
                                    const unsigned char** out, unsigned char* outlen,
                                    const unsigned char* in, unsigned int inlen) {
  // Currently this uses the standard selection algorithm in priority order.
  const uint8_t* alpn_data = &parsed_alpn_protocols[0];
  size_t alpn_data_size = parsed_alpn_protocols.size();

  if (SSL_select_next_proto(const_cast<unsigned char**>(out), outlen, alpn_data, alpn_data_size, in,
                            inlen) != OPENSSL_NPN_NEGOTIATED) {
    return SSL_TLSEXT_ERR_NOACK;
  } else {
    return SSL_TLSEXT_ERR_OK;
  }
}

} // namespace Ssl
} // namespace Envoy
