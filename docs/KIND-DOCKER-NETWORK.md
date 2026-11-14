# Kind Docker network migration (deferred)

`netscape.system.local-kubernetes` declares the Docker network `kind` with Linux bridge
`br-kind`, IPv4 `172.30.0.0/16`, IPv6 `fc00:f853:ccd:e793::/64`, bridge MTU 1500,
and masquerading enabled. Two IPv4 exceptions skip strict reverse-path filtering for
pod-sourced traffic entering that bridge: one for destinations in the configured pod
subnet (`10.244.0.0/16` by default), and one for destinations anywhere in the declared
Kind Docker IPv4 subnet (`172.30.0.0/16`). The latter persists a manually added
pod-to-control-plane exception: the control plane currently has `172.30.0.3`, but Kind
does not pin that address in the cluster config, so the declared rule intentionally
covers other addresses on the Kind network too (including workers and the gateway).
These rules bypass reverse-path filtering only; they do not generally open the firewall.
Keep the pod subnet option aligned with the `kubernetes-start` cluster configuration if
it changes.

**Do not delete the live network while the cluster is running.** The existing network
uses `br-9894f3219b8e` and has active cluster containers. Once this configuration is
activated, `kind-docker-network.service` will detect the bridge mismatch and fail with
a migration message; it will never replace the network. Both declared firewall rules
match `br-kind` only, so they will not fix pod traffic on the old bridge. **Do not
`nixos-rebuild switch` until a planned migration:** firewall reload removes the current
manual old-bridge rpfilter rules and would break running pod traffic while the new unit
refuses to replace the occupied network. No temporary old-bridge rule is declared here.
Plan a separate maintenance window to stop/delete the cluster and remove the old `kind`
network, then
start `kind-docker-network.service` to create the declared network before starting the
cluster. Back up any important cluster data and use the cluster project's own lifecycle
instructions; this repo intentionally does not automate that migration.

For a new cluster, run `systemctl start kind-docker-network.service` before
`kubernetes-start` cluster bootstrap and check that it succeeds. The unit requires and
runs after `docker.service`; it also starts automatically at boot as part of
`multi-user.target`. A manual bootstrap should still explicitly start/check it so a
fresh network cannot race with Kind's own network creation. Restart the unit to
recheck settings if it was already active.
