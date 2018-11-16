#pragma once

#include <functional>
#include <string>
#include <vector>

#include "sslimpl/context.h"

#include "openssl/ssl.h"

namespace SslImpl {

  int alpnSelectCallback(std::vector<uint8_t> parsed_alpn_protocols, const unsigned char** out, unsigned char* outlen, const unsigned char* in,
                         unsigned int inlen);

} // namespace SslImpl
