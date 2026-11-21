# Optional HTTPS with a Pi and Dynu

The Windows installer serves `http://multica.lan`, `http://multica-user.lan`
and `http://multica-admin.lan` on loopback. Enabling LAN access adds an HTTP
listener. Neither mode installs an ACME client, requests DNS credentials or
requires a certificate. Use this guide only if you want a separate HTTPS
entry point for all three pages.

In this example, the Pi runs acme.sh and nginx. The browser connects to
the Pi over HTTPS. The Pi proxies to the Windows portal over HTTP on your
trusted LAN. The certificate and private key stay on the Pi. You can keep
using the existing HTTP bookmarks, including when the Pi proxy is offline.

## 1. Request one certificate for the three public DNS names

Run these commands on the Pi as the same user who installed acme.sh.
Leave ddclient running with its existing settings. In Dynu's control panel,
open **API Credentials** and find the OAuth client ID and secret for the
account managing your hostname. Dynu accepts a SHA-256 password hash for
IP updates. The ACME plugin needs the OAuth secret exactly as issued.
The plugin saves its credentials for renewals,
so keep the acme.sh account directory private. [Dynu API credentials](https://www.dynu.com/en-US/Support/API)

In Bash, enter the values at the prompts. Replace `example.net`
with your actual Dynu hostname.

```bash
read -rp 'Dynu OAuth client ID: ' Dynu_ClientId
read -rsp 'Dynu OAuth secret: ' Dynu_Secret; echo
export Dynu_ClientId Dynu_Secret
zone=example.net
"$HOME/.acme.sh/acme.sh" --issue --server letsencrypt --dns dns_dynu --keylength ec-256 \
  -d "multica.$zone" -d "multica-user.$zone" -d "multica-admin.$zone"
```

`--dns dns_dynu` selects the provider plugin. Each `-d` supplies a name
to include in the certificate. The plugin finds the DNS zone automatically.
It publishes temporary TXT records such as
`_acme-challenge.multica.example.net` in **Dynu's public DNS**.
Let's Encrypt reads those records and signs the certificate. Keep the three
`.lan` names out of the request. There is no manual TXT value to paste,
router port to forward or inbound connection to the Pi during validation.
If Dynu refuses a TXT record, check the API credentials and your account's
DNS record permissions and quota. [acme.sh Dynu plugin](https://github.com/acmesh-official/acme.sh/wiki/dnsapi#dns_dynu)
· [Let's Encrypt DNS validation](https://letsencrypt.org/docs/challenge-types/#dns-01-challenge)

## 2. Set up the private route

1. Enable the [Windows portal's LAN listener](../hyperv/README.md#optional-lan-access).
   From the Pi, check that the portal answers. Substitute the Windows LAN
   address in `curl -I -H 'Host: multica.lan' http://192.168.1.50/`.
2. In Pi-hole's local DNS, point the three **certificate names** at the
   **Pi's LAN IP**. Keep the three **.lan names** pointing at **Windows**
   for clients using the HTTP portal. The public DDNS address can continue
   pointing to your router. Clients need to use Pi-hole for the local answers.
3. Use an available HTTPS port on the Pi. The example uses **8443** so it
   can coexist with Pi-hole's admin page on 443. On an existing Pi-hole
   host check listeners with `sudo ss -ltnp`. If installing nginx, disable
   its packaged default site if that site would claim Pi-hole's port 80.
   Leave Pi-hole's own listener in place.

## 3. Install the certificate and configure nginx

Run this as the acme.sh user. The nginx master in this example starts as
root and can read this directory. acme.sh remembers the install paths and
reload command for future renewals.

```bash
install -d -m 700 "$HOME/multica-tls"
umask 077
"$HOME/.acme.sh/acme.sh" --install-cert --ecc -d "multica.$zone" \
  --key-file "$HOME/multica-tls/privkey.pem" \
  --fullchain-file "$HOME/multica-tls/fullchain.pem" \
  --reloadcmd 'sudo -n systemctl reload nginx'
```

Have nginx installed and running for the reload. The renewal user needs
passwordless permission for that specific reload command (or omit `sudo -n`
if acme.sh is running as root). If the service cannot traverse your home
directory, use a dedicated protected certificate directory accessible to
its master and writable by your renewal user. Use the deployed files above
in nginx. [acme.sh certificate installation and reload](https://github.com/acmesh-official/acme.sh#3-install-the-certificate-to-apachenginx)

Copy [the nginx example](examples/multica-https.conf) into the nginx
`http` configuration, typically `/etc/nginx/conf.d/multica-https.conf`.
Replace **every** `example.net`, the example addresses and subnet,
and both PEM paths. It assumes the default Windows portal port 80. The
example sets `map_hash_bucket_size` to fit the hostname and origin pairs.
If your `http` config already sets it, keep one setting large enough for
the substituted names. The proxy translates the three browser hostnames to the matching portal
names, including login redirects and the management page's origin check.

```bash
sudo nginx -t && sudo systemctl reload nginx
```

Open `https://multica.example.net:8443/` from a client using
Pi-hole. Follow both workspace links, sign in to each, and check that
**Manage installation** can refresh status. The browser should show a
trusted certificate without an exception. The separate HTTP portal remains
reachable from the allowed LAN subnet.

## Renewal and removal

Check `crontab -l` as the acme.sh installation user for its scheduled
`--cron` job. It renews before expiry using the Dynu plugin, installs the
new files, and runs the saved reload command. Confirm the certificate
actually served after renewal, for example:

```bash
openssl s_client -connect "multica.$zone:8443" -servername "multica.$zone" </dev/null 2>/dev/null |
  openssl x509 -noout -issuer -enddate -ext subjectAltName
```

To retire only this HTTPS entry point, remove its nginx site, test and
reload nginx, and remove its three Pi-hole certificate-name records.
`"$HOME/.acme.sh/acme.sh" --remove --ecc -d "multica.$zone"` stops renewal for
this order. The ordinary Windows HTTP deployment and ddclient are independent.
