#!/usr/bin/env python3
"""Patch bloodhound/ad/authentication.py: add LDAP signing for NTLM and Kerberos.

Four changes:
1. Insert _BHSignedSocket class — SASL security layer socket wrapper.
2. Replace NTLM branch — manual SPNEGO NTLM exchange with session-key extraction.
3. Save session key after TGS exchange — for Kerberos signing.
4. Apply GSSAPI signing after successful Kerberos bind.

Run from the bloodhound-ce source root (Nix postPatch cwd).
"""

TARGET = "bloodhound/ad/authentication.py"

# ---- Patch 1: _BHSignedSocket class ----
# Inserted just before "class ADAuthentication(object):"
_BHSIGNEDSOCKET_CLASS = """\
class _BHSignedSocket:
    \"\"\"Wraps a real socket to add SASL security layer (GSSAPI or NTLM SPNEGO).\"\"\"
    def __init__(self, sock, gss=None, session_key=None, spnego_cipher=None):
        self._sock = sock
        self._gss = gss
        self._session_key = session_key
        self._spnego_cipher = spnego_cipher
        self._seq = 0
        self._recv_buf = b\"\"

    def sendall(self, data, flags=0):
        if self._spnego_cipher:
            sig, wrapped = self._spnego_cipher.encrypt(data)
            payload = sig.getData() + wrapped
        else:
            wrapped, sig = self._gss.GSS_Wrap_LDAP(
                self._session_key, data, self._seq, \"init\", encrypt=True)
            payload = sig + wrapped
        framed = len(payload).to_bytes(4, \"big\") + payload
        self._sock.sendall(framed, flags)
        self._seq += 1

    def recv(self, bufsize, flags=0):
        while len(self._recv_buf) < 4:
            chunk = self._sock.recv(bufsize, flags)
            if not chunk:
                return b\"\"
            self._recv_buf += chunk
        msg_len = int.from_bytes(self._recv_buf[:4], \"big\")
        total_needed = 4 + msg_len
        while len(self._recv_buf) < total_needed:
            chunk = self._sock.recv(bufsize, flags)
            if not chunk:
                return b\"\"
            self._recv_buf += chunk
        payload = self._recv_buf[4:total_needed]
        self._recv_buf = self._recv_buf[total_needed:]
        if self._spnego_cipher:
            _, plaintext = self._spnego_cipher.decrypt(payload)
        else:
            plaintext, _ = self._gss.GSS_Unwrap_LDAP(
                self._session_key, payload, 0, \"init\")
        return plaintext

    def __getattr__(self, name):
        return getattr(self._sock, name)
"""

CLASS_ANCHOR = "class ADAuthentication(object):"

# ---- Patch 2: NTLM branch replacement ----
# Upstream's simple conn.bind() replaced with manual SPNEGO NTLM exchange
# that extracts the session key and wraps the socket with _BHSignedSocket.
OLD_NTLM = (
    "        if not bound and self.auth_method in ('auto','ntlm'):\n"
    "            conn = Connection(server, user=ldaplogin, auto_referrals=False, password=ldappass, authentication=NTLM, receive_timeout=60, auto_range=True)\n"
    "            logging.debug('Authenticating to LDAP server with NTLM')\n"
    "            if self.ldap_channel_binding:\n"
    "                from ldap3 import TLS_CHANNEL_BINDING\n"
    "                logging.debug(\"Using LDAPS channel binding\")\n"
    "                protocol = 'ldaps'\n"
    "                channel_binding = {\"channel_binding\": TLS_CHANNEL_BINDING}\n"
    "                conn = Connection(server, user=ldaplogin, password=ldappass, authentication=NTLM, auto_referrals=False, receive_timeout=60, auto_range=True, **channel_binding)\n"
    "            else:\n"
    "                conn = Connection(server, user=ldaplogin, auto_referrals=False, password=ldappass, authentication=NTLM, receive_timeout=60, auto_range=True)\n"
    "            bound = conn.bind()"
)

NEW_NTLM = (
    "        if not bound and self.auth_method in ('auto','ntlm'):\n"
    "            conn = Connection(server, user=ldaplogin, auto_referrals=False,\n"
    "                              password=ldappass, authentication=NTLM,\n"
    "                              receive_timeout=60, auto_range=True)\n"
    "            logging.debug('Authenticating to LDAP server with NTLM (SPNEGO)')\n"
    "            try:\n"
    "                conn.open(read_server_info=False)\n"
    "\n"
    "                from impacket.ntlm import getNTLMSSPType1, getNTLMSSPType3\n"
    "                from impacket.spnego import SPNEGO_NegTokenInit, SPNEGO_NegTokenResp, TypesMech, SPNEGOCipher\n"
    "                from impacket.ntlm import NTLMAuthChallenge, VERSION\n"
    "\n"
    "                version = VERSION()\n"
    "                version['ProductMajorVersion'], version['ProductMinorVersion'], version['ProductBuild'] = 10, 0, 19041\n"
    "                negotiate = getNTLMSSPType1(\"\", self.userdomain,\n"
    "                                             signingRequired=True, use_ntlmv2=True,\n"
    "                                             version=version)\n"
    "                blob = SPNEGO_NegTokenInit()\n"
    "                blob['MechTypes'] = [TypesMech['NTLMSSP - Microsoft NTLM Security Support Provider']]\n"
    "                blob['MechToken'] = negotiate.getData()\n"
    "\n"
    "                request = bind_operation(conn.version, SASL, None, None,\n"
    "                                         'GSS-SPNEGO', blob.getData())\n"
    "                response = conn.post_send_single_response(\n"
    "                    conn.send('bindRequest', request, None))\n"
    "                result = response[0]\n"
    "                if result['result'] != 14:\n"
    "                    raise Exception('NTLM negotiate failed: %s' % result)\n"
    "\n"
    "                serverSaslCreds = result['saslCreds']\n"
    "                spnegoTokenResp = SPNEGO_NegTokenResp(serverSaslCreds)\n"
    "                type2 = spnegoTokenResp['ResponseToken']\n"
    "\n"
    "                type3, exportedSessionKey = getNTLMSSPType3(\n"
    "                    negotiate, type2,\n"
    "                    self.username, self.password, self.userdomain,\n"
    "                    self.lm_hash if self.lm_hash else \"\",\n"
    "                    self.nt_hash if self.nt_hash else \"\",\n"
    "                    service='ldap', use_ntlmv2=True, version=version)\n"
    "                import hmac as _hmac\n"
    "                newmic = _hmac.new(exportedSessionKey,\n"
    "                                   negotiate.getData()\n"
    "                                   + NTLMAuthChallenge(type2).getData()\n"
    "                                   + type3.getData(), 'md5').digest()\n"
    "                type3['MIC'] = newmic\n"
    "\n"
    "                spnego_cipher = SPNEGOCipher(\n"
    "                    flags=negotiate['flags'],\n"
    "                    randomSessionKey=exportedSessionKey)\n"
    "\n"
    "                blob_resp = SPNEGO_NegTokenResp()\n"
    "                blob_resp['ResponseToken'] = type3.getData()\n"
    "                mech_list_mic = spnego_cipher.sign(\n"
    "                    b\"\\x30\\x0c\\x06\\n+\\x06\\x01\\x04\\x01\\x827\\x02\\x02\\n\",\n"
    "                    0, reset_cipher=True).getData()\n"
    "                blob_resp['mechListMIC'] = mech_list_mic\n"
    "\n"
    "                request = bind_operation(conn.version, SASL, None, None,\n"
    "                                         'GSS-SPNEGO', blob_resp.getData())\n"
    "                response = conn.post_send_single_response(\n"
    "                    conn.send('bindRequest', request, None))\n"
    "                result = response[0]\n"
    "\n"
    "                if result['result'] == 0:\n"
    "                    conn.socket = _BHSignedSocket(\n"
    "                        conn.socket, spnego_cipher=spnego_cipher)\n"
    "                    conn.bound = True\n"
    "                    conn.refresh_server_info()\n"
    "                    bound = True\n"
    "                else:\n"
    "                    logging.error('NTLM SPNEGO bind failed: %s', result)\n"
    "            except Exception as exc:\n"
    "                logging.debug(traceback.format_exc())\n"
    "                logging.warning('NTLM SPNEGO auth to LDAP failed: %s', exc)\n"
    "                bound = False"
)

# ---- Patch 3: Save session key after getKerberosTGS ----
# Capture the cipher and session key for later GSSAPI Kerberos signing.
OLD_TGS = (
    "        tgs, cipher, _, sessionkey = getKerberosTGS(servername, self.domain, self.kdc,\n"
    "                                                                self.tgt['KDC_REP'], self.tgt['cipher'], self.tgt['sessionKey'])"
)

NEW_TGS = (
    "        tgs, cipher, _, sessionkey = getKerberosTGS(servername, self.domain, self.kdc,\n"
    "                                                self.tgt['KDC_REP'], self.tgt['cipher'], self.tgt['sessionKey'])\n"
    "        self._bh_signing_sessionkey = sessionkey\n"
    "        self._bh_signing_cipher = cipher"
)

# ---- Patch 4: GSSAPI signing after successful bind ----
# After ldap_kerberos binds successfully, wrap the socket with GSSAPI signing.
OLD_REFRESH = (
    "            connection.refresh_server_info()\n"
    "        return response['result'] == 0"
)

NEW_REFRESH = (
    "            connection.refresh_server_info()\n"
    "        if self._bh_signing_sessionkey:\n"
    "            from impacket.krb5.gssapi import GSSAPI\n"
    "            gss = GSSAPI(self._bh_signing_cipher)\n"
    "            connection.socket = _BHSignedSocket(\n"
    "                connection.socket, gss=gss,\n"
    "                session_key=self._bh_signing_sessionkey)\n"
    "        return response['result'] == 0"
)


# ---- Patch functions (each checks idempotency) ----

def _patch_insert_class(text: str) -> str:
    """Insert _BHSignedSocket class before class ADAuthentication."""
    if "_BHSignedSocket" in text:
        print("_BHSignedSocket already present, skipping insert.")
        return text
    if CLASS_ANCHOR not in text:
        raise SystemExit(
            f"Anchor '{CLASS_ANCHOR}' not found in {TARGET}. "
            "Upstream authentication.py changed — update CLASS_ANCHOR "
            "in this script."
        )
    text = text.replace(
        CLASS_ANCHOR,
        _BHSIGNEDSOCKET_CLASS + "\n\n" + CLASS_ANCHOR,
    )
    assert "_BHSignedSocket" in text, "Failed to insert _BHSignedSocket"
    print("Inserted _BHSignedSocket class.")
    return text


def _patch_ntlm_branch(text: str) -> str:
    """Replace upstream NTLM bind with manual SPNEGO exchange."""
    if "SPNEGOCipher" in text:
        print("NTLM SPNEGO branch already present, skipping.")
        return text
    if OLD_NTLM not in text:
        raise SystemExit(
            f"OLD_NTLM block not found in {TARGET}. "
            "Upstream authentication.py NTLM branch changed — "
            "update OLD_NTLM in this script."
        )
    text = text.replace(OLD_NTLM, NEW_NTLM)
    assert OLD_NTLM not in text, "Failed to replace NTLM branch"
    print("Replaced NTLM branch with SPNEGO exchange.")
    return text


def _patch_save_session_key(text: str) -> str:
    """Save session key and cipher after getKerberosTGS."""
    if "_bh_signing_sessionkey" in text:
        print("Session key save already present, skipping.")
        return text
    if OLD_TGS not in text:
        raise SystemExit(
            f"OLD_TGS block not found in {TARGET}. "
            "Upstream getKerberosTGS call changed — update OLD_TGS "
            "in this script."
        )
    text = text.replace(OLD_TGS, NEW_TGS)
    assert "_bh_signing_sessionkey" in text, "Failed to insert session key save"
    print("Added session key save after getKerberosTGS.")
    return text


def _patch_gssapi_signing(text: str) -> str:
    """Wrap connection socket with GSSAPI signing after successful bind."""
    if "GSSAPI(self._bh_signing_cipher)" in text:
        print("GSSAPI signing already present, skipping.")
        return text
    if OLD_REFRESH not in text:
        raise SystemExit(
            f"OLD_REFRESH block not found in {TARGET}. "
            "Upstream ldap_kerberos bind success path changed — "
            "update OLD_REFRESH in this script."
        )
    text = text.replace(OLD_REFRESH, NEW_REFRESH)
    assert "GSSAPI(self._bh_signing_cipher)" in text, "Failed to insert Kerberos signing"
    print("Added GSSAPI Kerberos signing.")
    return text


def main() -> None:
    with open(TARGET) as f:
        text = f.read()

    text = _patch_insert_class(text)
    text = _patch_ntlm_branch(text)
    text = _patch_save_session_key(text)
    text = _patch_gssapi_signing(text)

    with open(TARGET, "w") as f:
        f.write(text)

    print(f"Patched {TARGET}: NTLM SPNEGO + Kerberos GSSAPI signing added.")


if __name__ == "__main__":
    main()