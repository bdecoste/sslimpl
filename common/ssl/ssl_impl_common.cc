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

std::string getSerialNumberFromCertificate(X509* cert) {
  ASN1_INTEGER* serial_number = X509_get_serialNumber(cert);
  BIGNUM* num_bn(BN_new());
  ASN1_INTEGER_to_BN(serial_number, num_bn);
  char* char_serial_number = BN_bn2hex(num_bn);
  BN_free(num_bn);
  if (char_serial_number != nullptr) {
    std::string serial_number(char_serial_number);

    // openssl is uppercase, boringssl is lowercase. So convert
    std::transform(serial_number.begin(), serial_number.end(), serial_number.begin(), ::tolower);
    
    OPENSSL_free(char_serial_number);
    return serial_number;
  }
  return "";
}
    
} // namespace Ssl
} // namespace Envoy
