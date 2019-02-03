+++
date = 2019-02-03
title = "Wireless printers on swaywm"
+++

## Wireless printers on swaywm

Here's how you add a wireless printer to [Sway][sway_url]. You'll need the following tools:

1. [CUPS][cups_url], the "standards-based, open source printing system"
2. [Avahi][avahi_url] for wireless support
3. `nss-mdns`, so we can refer to the printer as `<hostname>.local` (e.g. `myprinter.local`)

```bash
# Install the packages
$ yay -S cups avahi nss-mdns

# Start the cups service
$ systemctl start org.cups.cupsd.service

# Ensure you can see the CUPS web interface at localhost:631

# Start the Avahi daemon
$ systemctl start avahi-daemon.service
```

Now, enable hostname resolution in Avahi by following [the instructions on the
Arch Wiki][hostname_resolution_url].

```bash
# Find the printer on the local network
$ sudo lpinfo --include-schemes dnssd -v

# You should see something like:
# network dnssd://Canon%20MG5700%20series._ipp._tcp.local/?uuid=<some uuid>

# Add the printer to CUPS
$ sudo lpadmin \
  -p short-name-eg-canon-md5750 \
  -D "Full Name (e.g. 'Canon MG5750 Laserjet')" \
  -L "Location (e.g. 'Living Room') (Optional)" \
  -v dnssd://Canon%20MG5700...
```

If you did everything right so far, you should be able to see the printer in
the CUPS web interface (localhost:631). If you click on the printer's
name, it should say "Idle, Accepting Jobs."

Now, you can try to print your document. You can track your print job from
the CUPS web interface. If something goes wrong, you can see the error there.

### Bonus! Add custom printer drivers

To access advanced features of your printer, you may need to install a custom
driver. First, find the relevant drivers by searching the AUR for your printer
model. For me, it was the `cnijfilter2-mg7700` package.

Once you've done that, tell CUPS to assign the custom driver to the printer:

```bash
# Find the driver's ppd file
$ lpinfo -m
# It will be something like lsb/usr/canonmg5700.ppd

# And assign it in CUPS
$ sudo lpadmin -p canon-md5750 -m lsb/usr/canonmg5700.ppd
```

That's it!

## Troubleshooting

**My printer in CUPS is listed as disabled or not accepting new jobs**

Make sure you run:

```bash
$ sudo cupsenable <short-name>
$ sudo cupsaccept <short-name>
```

You may be able to do this from the web interface, but I was getting
permission denied errors.

**My print job fails because it can't find ghostscript**

You need to install `ghostscript`. In Arch, it's just `yay -S ghostscript`.

## References

- [Administering CUPS from the command line][administering_cups_url]
- [Arch Wiki / CUPS][arch_wiki_cups_url]

[cups_url]: https://www.cups.org
[sway_url]: https://swaywm.org
[avahi_url]: http://avahi.org
[hostname_resolution_url]: https://wiki.archlinux.org/index.php/Avahi#Hostname_resolution
[administering_cups_url]: https://current.workingdirectory.net/posts/2013/cups-cli-admin/
[arch_wiki_cups_url]: https://wiki.archlinux.org/index.php/CUPS
