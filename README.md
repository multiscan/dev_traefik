# Generic Traefik container for local development

### One traefik for all your dev apps

This repository is to demonstrate how to use the `external` network specification in `docker-compose` to enable communication between containers defined in different compositions. It also uses the nice auto-discover capabilities of traefik respond to all services that require it without having to touch anything in this directory.

## How to use it

### DNS
Traefik forward traffic to services based on their hostnames. Since it listens to a local address, there must be a name resolution for the browser to reach the traefik proxy and the various backends. This can be done in two ways:
 1. change your `/etc/hosts` file so that the desired name is resolved to localhost: 
    ```
    127.0.0.1    www.example.com
    ```
    This is the only option if you don't have access to the DNS for the domain you intend to use. If you have [dnsmasq][10] installed you can probably assign full subdomains like `*.dev.local` to `localhost` (not tested in person at least recently). 
 1. redirect all your domain (or a subdomain) to localhost in the dns of your domain. A line like the following will redirect any request in the subdomain `dev` to localhost. For example, if your domain were `example.com`, then `mywebapp.dev.example.com` would be resolved to localhost.
     ```
     *.dev 1800 IN A 127.0.0.1
     ```

### SSL Certificates
For **local domains** like `mywebapp.local`, the only choice is to auto-generate the certificates. The good thing is that browsers are more relaxed regarding validity of the certificate in this case. Still the easiest option is to use [mkcert][9] automatically as explained below.

For **global domains**, we cannot use the great feature of traefik of generating the _acme_ certificates from Let's encrypt because the dev machine is not reacheable from the internet. However, there are still two viable options that do not require generating a certificate for each service:

 1. Official wildcard certificates: generate a certificate for your `dev` subdomain and store it in a subdirectory of your `CRTDIR`. I do this using the procedure described [here][1] which uses Let's encrypt and works nicely (and free of charge) for domains registered with gandi.net. The list of subdomains that you want traefik to be aware of have to be listed in the `DOMAINS` environment variable. So, if the domain is `jkldsa.com`, anything like `myapp.dev.jkldsa.com` will point to localhost and reach traefik. Since the certificate is valid forr all hosts in the `*.dev.jkldsa.com`, traefik will not have to generate a new one and you will avoid complains from the browser.
 1. Use [mkcert][9] to generate cerificates on the fly for the sub-domains you intend to use. In this case, all you have to do is to list the domains in the `MKCERT_DOMAINS` environment variable. 

## Configuration

1. provide a directory with a valid wildcard certificate and key as the `CRTDIR` env variable;
1. provide `DOMAINS` andd `MKCERT_DOMAINS` environment variables listing the domains you want to use;
1. make sure that traefik is running: `make up`;
1. add labels and network to your app's `docker-compose.yml` file so that it can be added automatically to the list of services. See the example.

## Links
 - [Gandi & LE Certificate Generation][1]
 - [mkcert][9]
 - [Traefik 1.7 documentation][2]
 - [Traefik 2.2 documentation][3]
 - [Traefik and TLS HowTo blog post][4], [see also][5]
 - [Discussion about ssh traffik with Traefik][6]
 - [OpenSSL commands][7]
 - [socat man page][8]

[1]: https://github.com/multiscan/GandiLetsEncryptCertificates
[2]: https://docs.traefik.io/v1.7/
[3]: https://docs.traefik.io/v2.2/
[4]: https://containo.us/blog/traefik-2-tls-101-23b4fbee81f1/
[5]: https://jimfrenette.com/2018/03/ssl-certificate-authority-for-docker-and-traefik/
[6]: https://community.containo.us/t/routing-ssh-traffic-with-traefik-v2/717/12
[7]: https://www.sslshopper.com/article-most-common-openssl-commands.html
[8]: https://linux.die.net/man/1/socat
[9]: https://github.com/FiloSottile/mkcert
[10]: https://thekelleys.org.uk/dnsmasq/doc.html
