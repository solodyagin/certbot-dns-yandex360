# certbot-dns-pddyandex
Yandex API360 DNS for certbot --manual-auth-hook --manual-cleanup-hook

Install and renew Let's encrypt wildcard ssl certificate for domain *.site.com using Yandex API360:

#### 1) Clone this repo and set the OAuth Token
```bash
git clone https://github.com/actionm/certbot-dns-pddyandex/ && cd ./certbot-dns-pddyandex
```

#### 2) Set OAuth Token

Get your Yandex API360 OAuth token from https://yandex.ru/dev/api360/doc/concepts/access.html )

```bash
nano ./config.sh
```

#### 3) Install CertBot from git
```bash
cd ../ && git clone https://github.com/certbot/certbot && cd certbot
```

#### 4) Generate wildcard
```bash
./letsencrypt-auto certonly --manual-public-ip-logging-ok --agree-tos --email info@site.com --renew-by-default -d site.com -d *.site.com --manual --manual-auth-hook ../certbot-dns-pddyandex/authenticator.sh --manual-cleanup-hook ../certbot-dns-pddyandex/cleanup.sh --preferred-challenges dns-01 --server https://acme-v02.api.letsencrypt.org/directory
```

#### 5) Force Renew
```bash
./letsencrypt-auto renew --force-renew --manual --manual-auth-hook ../certbot-dns-pddyandex/authenticator.sh --manual-cleanup-hook ../certbot-dns-pddyandex/cleanup.sh --preferred-challenges dns-01 --server https://acme-v02.api.letsencrypt.org/directory
```