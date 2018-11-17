#include <algorithm>
#include <memory>
#include <string>
#include <vector>
#include <cstring>

#include "openssl/ssl.h"
#include "openssl/hmac.h"
#include "openssl/rand.h"
#include "openssl/x509v3.h"

#include "common/ssl/ssl_impl.h"

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

bssl::UniquePtr<SSL> newSsl(SSL_CTX *ctx) {
  return bssl::UniquePtr<SSL>(SSL_new(ctx));
}

int set_strict_cipher_list(SSL_CTX *ctx, const char *str) {
  SSL_CTX_set_cipher_list(ctx, str);
  STACK_OF(SSL_CIPHER) *ciphers = SSL_CTX_get_ciphers(ctx);
  char *dup = strdup(str);
  char *token = std::strtok(dup, ":[]|");
  while (token != NULL) {
    bool found=false;
    for (int i = 0; i < sk_SSL_CIPHER_num(ciphers); i++) {
      const SSL_CIPHER *cipher = sk_SSL_CIPHER_value(ciphers, i);
      std::string str1(token);
      if (str1.compare(SSL_CIPHER_get_name(cipher)) == 0){
        found = true;
      }
    }
    if (!found){
      delete dup;
      return -1;
    }
    token = std::strtok(NULL, ":[]|");
  }

  delete dup;
  return 1;
}

} // namespace Ssl
} // namespace Envoy
