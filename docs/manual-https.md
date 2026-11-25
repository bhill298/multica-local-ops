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

## 1. Install acme.sh on the Pi

Use the Linux account that will own the certificate and its renewal job.
Run the upstream installer once, then check the executable and cron entry:

```bash
curl -fsSL https://get.acme.sh | sh
"$HOME/.acme.sh/acme.sh" --version
crontab -l | grep -F -- '--cron'
```

The full executable path works in the current shell. If you have already
installed acme.sh, start with the version and cron checks. If the installer
reported a missing crontab, install and enable cron on the Pi, then run
`"$HOME/.acme.sh/acme.sh" --install-cronjob` as the certificate owner.
[Upstream installation instructions](https://github.com/acmesh-official/acme.sh#1-how-to-install)

## 2. Request one certificate for the three public DNS names

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

## 3. Set up the private route

1. Enable the [Windows portal's LAN listener](../hyperv/README.md#optional-lan-access).
   From the Pi, check that the portal answers. Substitute the Windows LAN
   address in `curl -I -H 'Host: multica.lan' http://192.168.1.50/`.
2. In the Pi-hole web interface under **Local DNS Records**, point the three **certificate names** at the
   **Pi's LAN IP**. Keep the three **.lan names** pointing at **Windows**
   for clients using the HTTP portal. The public DDNS address can continue
   pointing to your router. Clients need to use Pi-hole for the local answers.
3. Check each answer directly. In this and the following commands, replace
   the example address with the Pi's LAN IP. All three answers should be
   that address. If a client still gets the public address, check which
   DNS servers it uses, including any resolver advertised over IPv6.

```bash
pi_ip=192.168.1.2
for name in multica multica-user multica-admin; do
  dig @"$pi_ip" "$name.$zone" A +short
done
```

## 4. Install nginx and prepare the site

On Raspberry Pi OS or Debian:

```bash
sudo apt update && sudo apt install nginx
sudo ss -ltnp '( sport = :80 or sport = :443 or sport = :8443 )'
ls -l /etc/nginx/sites-enabled/
```

Pi-hole can keep ports 80 and 443. This nginx site uses **8443**.
If nginx reports `address already in use` on port 80, inspect the enabled
listeners:

```bash
sudo grep -nE '^[[:space:]]*listen[[:space:]]' /etc/nginx/sites-enabled/* /etc/nginx/conf.d/*.conf
```

If `sites-enabled/default` is the symlink to the unused packaged
`sites-available/default` and declares `listen 80` or `listen [::]:80`,
disable just that link with `sudo unlink /etc/nginx/sites-enabled/default`.
The packaged file and Pi-hole's web service stay in place.

Copy [multica-https.conf](examples/multica-https.conf) to
`/etc/nginx/conf.d/multica-https.conf` on the Pi. Before reloading nginx,
edit these values in the installed copy:

| Template value | Use on your network |
| --- | --- |
| Every occurrence of `example.net` | The same Dynu hostname you assigned to `zone`, including in the host map, origin map, `server_name` and redirects |
| `listen 192.168.1.2:8443 ssl` | The Pi's own LAN IP and an available HTTPS port |
| `proxy_pass http://192.168.1.50:80` | The Windows PC's LAN IP and portal port (default 80) |
| `allow 192.168.1.0/24` | The subnet used by your LAN clients |
| Both paths under `/home/pi/multica-tls/` | Absolute paths to the PEM files installed in the next step |

Keep the three upstream `.lan` names. If you change 8443, update the origin
map and redirects too. If nginx already sets `map_hash_bucket_size` in
its `http` configuration, keep one setting large enough for the new names.

## 5. Install the certificate and bring up HTTPS

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

The install command copies the files and then runs its reload hook. If
nginx failed to start during package installation, the PEM files can be in
place even though that first reload failed. After fixing the site, test
the config and start nginx if necessary:

```bash
sudo nginx -t && sudo systemctl reload-or-restart nginx
```

For subsequent edits with nginx running, use `sudo nginx -t && sudo
systemctl reload nginx`. For unattended renewal, the certificate owner
needs passwordless permission for the specific reload command (omit
`sudo -n` if acme.sh runs as root). Test the hook as that user with
`sudo -k -n systemctl reload nginx` once the site is healthy. If it
reports that a password is required, configure the narrowly scoped reload
permission before relying on cron. If the service cannot traverse your home
directory, use a dedicated protected certificate directory accessible to
its master and writable by your renewal user. Use the deployed files above
in nginx. [acme.sh certificate installation and reload](https://github.com/acmesh-official/acme.sh#3-install-the-certificate-to-apachenginx)

## 6. Verify from a LAN client

In Windows PowerShell, replace the example zone and run:

```powershell
$zone = 'example.net'
curl.exe -I "https://multica.${zone}:8443/"
curl.exe -I "https://multica.${zone}:8443/admin"
```

Expect **200 OK** on the first request and **302 Found** on the second,
with `Location: https://multica-admin.<your-zone>:8443/login`. These
checks passed on the live deployment. The daily redirect, both dashboard
login pages and the management page also responded with normal certificate
verification. Scheduled renewal and reload have yet to be observed there.

| Symptom seen during setup | What to check |
| --- | --- |
| `bind() ...:8443 failed (99: Cannot assign requested address)` | Check `ip -4 addr` on the Pi. Replace the template's listen address with an address assigned to the Pi. |
| Port 80 already in use | Check the nginx default site in step 4. Leave Pi-hole on port 80. |
| Windows curl reports `SEC_E_UNTRUSTED_ROOT` | In the live test, curl reached the router's public address and saw the router's certificate. Compare normal DNS with the pinned request below before changing trust settings. |
| nginx returns `421 Misdirected Request` | In the live test the host map still contained `example.net`. Check `sudo grep -nF 'example.net' /etc/nginx/conf.d/multica-https.conf`, replace all remaining examples, then test and reload. |

To isolate DNS while keeping TLS verification enabled:

```powershell
$piIP = '192.168.1.2' # Substitute the Pi's address.
curl.exe --noproxy "*" --resolve "multica.${zone}:8443:${piIP}" -I "https://multica.${zone}:8443/"
```

A 200 only with `--resolve` points to client DNS. A refused connection even
with `--resolve` calls for checking the nginx service and its 8443 listener.

Open `https://multica.example.net:8443/` from a client using
Pi-hole. Follow both workspace links, sign in to each, and check that
**Manage installation** can refresh status. The browser should show a
trusted certificate without an exception. The separate HTTP portal remains
reachable from the allowed LAN subnet.

## 7. Reach the same HTTPS site over WireGuard

Get HTTPS working on Wi-Fi first. A remote client can then use the same
bookmarks and certificate. In this example the router runs WireGuard, the
VPN subnet is `10.77.0.0/24`, its gateway is `10.77.0.1`, and the Pi is
`192.168.1.2`. Substitute your own addresses throughout.

### Set up the tunnel and DNS

1. Enable the router's WireGuard server, choose a VPN subnet that doesn't
   overlap the LAN or the client's usual networks, and import a separate
   peer profile on each device. Point the endpoint at the router's public
   IP or DDNS name. Only the WireGuard UDP listener needs to be reachable
   from the internet. Keep TCP 8443 private.
2. Route the Pi's LAN address through the tunnel. A full-tunnel profile
   already covers it. With split tunneling, include the Pi and the DNS
   resolver addresses in the client's allowed routes. Allow VPN clients
   to reach nginx on TCP 8443 and their resolver on UDP and TCP 53.
3. On Wi-Fi, configure the router's LAN DHCP settings to advertise Pi-hole.
   If the LAN advertises IPv6 DNS, supply Pi-hole there too. WireGuard
   clients use the `DNS` entries from their imported profile. They don't
   renew a LAN DHCP lease when the tunnel connects.
4. For new profiles, you can set the VPN server's client DNS field to
   Pi-hole before exporting them. Check the generated profile and make
   sure Pi-hole accepts DNS from the routed VPN subnet. For existing
   profiles that already list the VPN gateway as DNS, configure the
   gateway to forward queries to Pi-hole. This works across domains and
   avoids editing each device. [UniFi WireGuard server setup](https://help.ui.com/hc/en-us/articles/115005445768-UniFi-Gateway-WireGuard-VPN-Server)

**UniFi settings used in the tested setup.** Under **Settings → Internet
→ active WAN**, set IPv4 DNS to manual and enter Pi-hole as primary. Leave
secondary empty unless you have a second resolver serving the same local
records. If using an IPv6 upstream, enter Pi-hole's stable, reachable IPv6
address there too. Set **Encrypted DNS** from **Auto** to **Off**. With Auto
enabled, the gateway returned the public address and a fresh lookup never
appeared in Pi-hole. These settings affect other clients using the gateway
for DNS. Pi-hole needs its own independent upstream to avoid a forwarding
loop. [UniFi DNS settings](https://help.ui.com/hc/en-us/articles/17484948645015-UniFi-DNS-Troubleshooting-Guide)

### Allow the VPN clients through nginx

In `/etc/nginx/conf.d/multica-https.conf`, keep your LAN rule and insert
the VPN rule **above** `deny all;` in the same `server` block:

```nginx
allow 192.168.1.0/24;
allow 10.77.0.0/24;
deny all;
```

This admits every peer on that subnet to the landing page, both dashboards
and the management controls. To admit one phone, use its assigned tunnel
address with `/32` instead. Run `sudo nginx -t && sudo systemctl reload nginx`.

### Verify from outside the LAN

From a client that can reach the VPN gateway, compare its DNS replies with
Pi-hole's. In PowerShell, substitute your zone and addresses:

```powershell
$zone = 'example.net'
$gateway = '10.77.0.1'
$pi = '192.168.1.2'
foreach ($name in 'multica', 'multica-user', 'multica-admin') {
    nslookup "$name.$zone" $pi
    nslookup "$name.$zone" $gateway
}
nslookup $zone $gateway
```

Both resolvers should return the Pi for all three HTTPS names. If the
bare zone is also your VPN endpoint, it should still return the router's
public address. Check each resolver listed in the profile, including IPv6,
from inside the tunnel. To trace forwarding, query a fresh name such as
`wg-test-<timestamp>.example.net` through the gateway and look for it in
Pi-hole's query log. Its appearance confirms forwarding even if the name
has no record. Flushing the client DNS cache doesn't clear the gateway's.

Finally, turn off Wi-Fi on the phone, connect WireGuard over cellular and
open the landing page and both dashboard links. In the tested setup, the
phone reached nginx with a valid certificate but received **403 Forbidden**
until its VPN address was allowed. If that happens, reload the page while
watching `sudo tail -f /var/log/nginx/error.log` for the denied client IP.
If the router translates peer addresses, nginx sees the translated address;
enforce any per-peer restrictions on the router in that case.

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
