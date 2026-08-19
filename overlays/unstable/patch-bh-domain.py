#!/usr/bin/env python3
"""Patch bloodhound/ad/domain.py: guard IPv6 resolution to not overwrite IPv4.

Upstream domain.py resolves both A and AAAA records. If IPv6 succeeds after
IPv4, `ip` is overwritten with the bracketed IPv6 address — but the DC may
not be reachable on v6, breaking the connection. This wraps the AAAA block
in `if not ip:` so IPv6 is only tried when IPv4 failed.

Run from the bloodhound-ce source root (Nix postPatch cwd).
"""

TARGET = "bloodhound/ad/domain.py"

# ---- Exact upstream block (unguarded AAAA resolution) ----
# When upstream domain.py changes, update this to match the new source
# and adjust NEW_AAAA accordingly.
OLD_AAAA = (
    "        try:\n"
    "            q6 = self.ad.dnsresolver.resolve(self.hostname, 'AAAA', tcp=self.ad.dns_tcp)\n"
    "            for rdata in q6:\n"
    "                logging.debug('LDAP server IPv6: %s', str(rdata.address))\n"
    "                logging.info('Testing resolved hostname connectivity %s', rdata.address)\n"
    "                try:\n"
    "                    logging.info('Trying LDAP connection to %s', rdata.address)\n"
    "                    _tmp_serv = ldap3.Server(rdata.address, connect_timeout=5)\n"
    "                    _conn = ldap3.Connection(_tmp_serv)\n"
    "                    _bind = _conn.bind()\n"
    "                except ldap3.core.exceptions.LDAPSocketOpenError:\n"
    "                    continue\n"
    "                except ldap3.core.exceptions.LDAPInvalidServerError:\n"
    "                    logging.error('LDAP3 did not like address: %s', rdata.address)\n"
    "                    continue\n"
    "                else:\n"
    "                    if _conn:\n"
    "                        logging.debug('Successful connection to: %s', rdata.address)\n"
    "                        ip = f'[{rdata.address}]'\n"
    "        except:\n"
    "            logging.debug('No AAAA records found')"
)

# ---- Replacement: same block guarded by `if not ip:` ----
NEW_AAAA = (
    "        if not ip:\n"
    "            try:\n"
    "                q6 = self.ad.dnsresolver.resolve(self.hostname, 'AAAA', tcp=self.ad.dns_tcp)\n"
    "                for rdata in q6:\n"
    "                    logging.debug('LDAP server IPv6: %s', str(rdata.address))\n"
    "                    logging.info('Testing resolved hostname connectivity %s', rdata.address)\n"
    "                    try:\n"
    "                        logging.info('Trying LDAP connection to %s', rdata.address)\n"
    "                        _tmp_serv = ldap3.Server(rdata.address, connect_timeout=5)\n"
    "                        _conn = ldap3.Connection(_tmp_serv)\n"
    "                        _bind = _conn.bind()\n"
    "                    except ldap3.core.exceptions.LDAPSocketOpenError:\n"
    "                        continue\n"
    "                    except ldap3.core.exceptions.LDAPInvalidServerError:\n"
    "                        logging.error('LDAP3 did not like address: %s', rdata.address)\n"
    "                        continue\n"
    "                    else:\n"
    "                        if _conn:\n"
    "                            logging.debug('Successful connection to: %s', rdata.address)\n"
    "                            ip = f'[{rdata.address}]'\n"
    "            except:\n"
    "                logging.debug('No AAAA records found')"
)


def main() -> None:
    with open(TARGET) as f:
        text = f.read()

    if OLD_AAAA not in text:
        raise SystemExit(
            f"OLD_AAAA block not found in {TARGET}. "
            "Upstream domain.py changed — update OLD_AAAA in this script "
            "to match the new source and adjust NEW_AAAA accordingly."
        )

    text = text.replace(OLD_AAAA, NEW_AAAA)
    assert OLD_AAAA not in text, "Failed to replace AAAA block"

    with open(TARGET, "w") as f:
        f.write(text)

    print(f"Patched {TARGET}: IPv6 guard added")


if __name__ == "__main__":
    main()