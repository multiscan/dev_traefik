# Generic Traefik container for local development

This repository is to demonstrate how to use the `external` network specification in `docker-compose` to enable communication between containers defined in different compositions. It also uses the nice auto-discover capabilities of traefik respond to all services that require it without having to touch anything in this directory.

Since this is meant for local development machine which is not reacheable from the internet, I cannot use the great feature of traefik of generating the _acme_ certificates from Let's encrypt. Therefore only the self-generated certificates are available.

## How I use it
In order to avoid having to generate a certificate for every single service, I use a valid wildcard certificate for a subdomain (_e.g._ `dev`) that is configured to point anything to `127.0.0.1`. This is done by adding the following line to the DNS record of the domain:

```
*.dev 1800 IN A 127.0.0.1
```

So, if the domain is `jkldsa.com`, anything like `myapp.dev.jkldsa.com` will point to localhost and reach traefik. Since the certificate is valid forr all hosts in the `*.dev.jkldsa.com`, traefik will not have to generate a new one and you will avoid complains from the browser.

## Configuration

1. provide a directory with a valid wildcard certificate and key as the `CRTDIR` env variable 
1. make sure that traefik is running: `make up`
1. add labels and network to your app's `docker-compose.yml` file so that it can be added automatically to the list of services. See the example.

## Generating wildcard certs with Let's Encrypt
Use [companion project](https://github.com/multiscan/dev_traefik)

## Generating the wildcard certificate

```
#
# Use this to generate self-signed cert
# openssl req -config cert.conf -new -x509 -sha256 -newkey rsa:2048 -nodes -keyout pippo.key.pem -days 365 -out pippo.cert.pem
# 
[ req ]
default_bits        = 2048
default_keyfile     = keyfile.pem
distinguished_name  = req_distinguished_name
req_extensions      = req_ext
x509_extensions     = x509_ext
string_mask         = utf8only
prompt              = no

# The Subject DN can be formed using X501 or RFC 4514 (see RFC 4519 for a description).
#   Its sort of a mashup. For example, RFC 4514 does not provide emailAddress.
[ req_distinguished_name ]
countryName         = CH
stateOrProvinceName = VD
localityName        = Lausanne
organizationName    = EPFL
commonName          = Giovanni Cangiani - EPFL
emailAddress        = giovanni.cangiani@epfl.ch

# Section x509_ext is used when generating a self-signed certificate. I.e., openssl req -x509 ...
[ x509_ext ]

subjectKeyIdentifier    = hash
authorityKeyIdentifier  = keyid,issuer

# You only need digitalSignature below. *If* you don't allow
#   RSA Key transport (i.e., you use ephemeral cipher suites), then
#   omit keyEncipherment because that's key transport.
basicConstraints = CA:FALSE
keyUsage         = digitalSignature, keyEncipherment
nsComment        = "OpenSSL Generated Certificate"
# subjectAltName   = @alternate_names

# Section req_ext is used when generating a certificate signing request. I.e., openssl req ...
[ req_ext ]
subjectKeyIdentifier = hash
basicConstraints     = CA:FALSE
keyUsage             = digitalSignature, keyEncipherment
# subjectAltName       = @alternate_names
nsComment            = "OpenSSL Generated Certificate"

# [ alternate_names ]
# DNS.1 = idevelopsrv24.epfl.ch
# DNS.2 = idev-fsd-redmine.epfl.ch
```


## References
 * Regarding [certificate generation](https://jimfrenette.com/2018/03/ssl-certificate-authority-for-docker-and-traefik/)
 * https://www.sslshopper.com/article-most-common-openssl-commands.html

