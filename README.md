Archiver
========

This is a bundle of software for managing image and video uploads.

## Configuration

Add a resolver to your system to route `.dev` domains to dnsmasq:

```
sudo mkdir -pv /etc/resolver
sudo bash -c 'echo "nameserver 127.0.0.1" > /etc/resolver/dev'
```

Add pf rules to forward ports 80 and 443 on localhost to non-privileged ports:

```
sudo bash -c 'echo "rdr-anchor \"forwarding\"" > /etc/pf-local-dev.conf'
sudo bash -c 'echo "load anchor \"forwarding\" from \"/etc/pf.anchors/com.dev\"" >> /etc/pf-local-dev.conf'

sudo bash -c 'echo "rdr pass on lo0 inet proto udp from any to 127.0.0.1 port 53 -> 127.0.0.1 port 8053" > /etc/pf.anchors/com.dev'
sudo bash -c 'echo "rdr pass on lo0 inet proto tcp from any to 127.0.0.1 port 80 -> 127.0.0.1 port 8088" >> /etc/pf.anchors/com.dev'
sudo bash -c 'echo "rdr pass on lo0 inet proto tcp from any to 127.0.0.1 port 443 -> 127.0.0.1 port 8443" >> /etc/pf.anchors/com.dev'
```

Enable port forwarding (this should be re-run after each reboot):

```
sudo pfctl -ef /etc/pf-local-dev.conf
```


## Usage

```bash
brew bundle
bundle exec rake reset
foreman start
```

Note that you cannot run foreman with `bundle exec`, or the fact that it is loading bundler Gemfiles from projects in subdirectories
will cause problems.

