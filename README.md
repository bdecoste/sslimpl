# Envoy Proxy OpenSSL Implementation
This project contains the source and the script for replacing [BoringSSL](https://opensource.google.com/projects/boringssl) with [OpenSSL](https://www.openssl.org) in [Envoy](https://github.com/envoyproxy/envoy).

## Replacing BoringSSL
To replace [BoringSSL](https://opensource.google.com/projects/boringssl) with [OpenSSL](https://www.openssl.org) in the [Envoy](https://github.com/envoyproxy/envoy) proxy simply run the [openssl.sh](https://github.com/bdecoste/sslimpl/blob/master/openssl.sh) script with the location of the Envoy source and "OPENSSL" are parameters. For example:

```
./openssl.sh /home/workspaces/envoy OPENSSL
```
## Details

### Abstraction Layer
[Envoy](https://github.com/envoyproxy/envoy) abstracts (WIP) the areas where BoringSSL and OpenSSL differ. Envoy provides a [BoringSSL](https://opensource.google.com/projects/boringssl) implementation of this abstraction layer. An example of the abstraction layer can be seen [here](https://github.com/bdecoste/envoy/blob/openssl-impl/source/common/ssl/ssl_impl_common.h).

### Bazel
The script modifies several of the [Envoy](https://github.com/envoyproxy/envoy) [Bazel](https://bazel.build) configuration files to:

* Remove the [BoringSSL](https://opensource.google.com/projects/boringssl) dependency
* Add a dependency on [OpenSSL](https://www.openssl.org)
* Replace the local [OpenSSL](https://www.openssl.org)-based libaries, including the implementation of the absraction layer, with external libraries from this project. 
* Replace the BoringSSL-based versions of Envoy dependencies with the OpenSSL-based versions (e.g. [jwt\_verify\_lib](https://github.com/bdecoste/jwt_verify_lib/tree/openssl-master))

### OpenSSL Libraries
This project assumes the [OpenSSL](https://www.openssl.org) libraries (i.e. libssl.a and libcrypto.a) are located in /usr/local/lib64. This location may be modified in the [WORKSPACE](https://github.com/bdecoste/sslimpl/blob/master/WORKSPACE) file. 




