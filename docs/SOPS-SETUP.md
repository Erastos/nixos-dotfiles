# SOPS Setup Guide

This guide explains how to configure SOPS to edit encrypted secrets files directly without environment variables.

## Overview

This configuration allows you to run `sops secrets/secrets.yaml` directly by using SOPS's default key discovery mechanism. The age key is stored at `~/.config/sops/age/keys.txt`, which SOPS automatically checks.

## Initial Setup

### 1. Rebuild NixOS Configuration

First, apply the configuration changes that add the necessary packages and directory structure:

```bash
# On Trinity
sudo nixos-rebuild switch --flake '/home/netscape/nixos-dotfiles#Trinity' -v

# On Neo
sudo nixos-rebuild switch --flake '/home/netscape/nixos-dotfiles#Neo' -v
```

This will:
- Install the `ssh-to-age` package
- Create the `~/.config/sops/age/` directory structure
- Add the `secrets` shell alias

### 2. Convert SSH Host Key to Age Format

Run these commands on each host (Trinity and Neo) to convert the SSH host key:

```bash
# Convert SSH host key to age private key
sudo ssh-to-age -private-key -i /etc/ssh/ssh_host_ed25519_key > /tmp/age-key.txt

# Move to SOPS default location
mkdir -p ~/.config/sops/age
mv /tmp/age-key.txt ~/.config/sops/age/keys.txt

# Set correct permissions (important!)
chmod 600 ~/.config/sops/age/keys.txt
```

### 3. Verify the Conversion

Check that the public key matches what's configured in `.sops.yaml`:

```bash
age-keygen -y ~/.config/sops/age/keys.txt
```

**Expected output:**
- **Trinity:** `age1t0n4rl8jjsclpxd6s2tme4ehpcyuqd07u0klpq34sqmvc7dgyatq3483p5`
- **Neo:** `age1csa9g8m07z3zpplzdrtj63vmcegk7lpyzqytvtkyewx3jk83wcgqmjxs5l`

These should match the keys defined in `.sops.yaml` as `trinity_age` and `neo_age`.

### 4. Test SOPS Access

```bash
# From anywhere in the filesystem using the alias
secrets

# Or explicitly
cd ~/nixos-dotfiles
sops secrets/secrets.yaml
```

SOPS should open the secrets file in your editor without requiring any environment variables.

## Usage

### Editing Secrets

Use any of these methods:

```bash
# Method 1: Use the alias (from anywhere)
secrets

# Method 2: Direct command
cd ~/nixos-dotfiles
sops secrets/secrets.yaml

# Method 3: Full path
sops ~/nixos-dotfiles/secrets/secrets.yaml
```

### Adding New Secrets

Edit the file with SOPS and add new keys:

```bash
secrets
```

Add your secrets in YAML format:
```yaml
Trinity:
    htb:
        api_key: your_key_here
    new_service:
        password: your_password_here
```

Save and exit. SOPS will automatically encrypt the values.

### Re-encrypting After Key Changes

If you add a new host or rotate keys, re-encrypt the secrets file:

```bash
cd ~/nixos-dotfiles
sops updatekeys secrets/secrets.yaml
```

## Configuration Files

### Modified Files

This setup modified the following configuration files:

1. **`/home/netscape/nixos-dotfiles/modules/packages/devops.nix`**
   - Added `ssh-to-age` package

2. **`/home/netscape/nixos-dotfiles/modules/home/shell.nix`**
   - Created `~/.config/sops/age/` directory structure
   - Added `secrets` shell alias

### SOPS Configuration

The SOPS configuration is defined in:

- **`.sops.yaml`** - Defines age recipients and encryption rules
- **`modules/system/secrets.nix`** - System-level sops-nix configuration

## How It Works

### Key Discovery

SOPS automatically looks for age keys in these locations (in order):

1. `SOPS_AGE_KEY_FILE` environment variable (if set)
2. `~/.config/sops/age/keys.txt` (our configuration)
3. `~/.config/sops/age/keys.txt` via XDG_CONFIG_HOME

Since we place the key at `~/.config/sops/age/keys.txt`, no environment variables are needed.

### SSH to Age Conversion

The SSH host key (`/etc/ssh/ssh_host_ed25519_key`) is converted to age format because:
- SOPS uses age encryption
- sops-nix already uses the SSH host key for system-level decryption
- This keeps encryption keys consistent across the system

## Troubleshooting

### Error: "no key could be found to decrypt the data key"

**Cause:** The age key doesn't match the recipients in `.sops.yaml`

**Solution:** Verify the public key matches:
```bash
age-keygen -y ~/.config/sops/age/keys.txt
```

Compare output with the age keys in `.sops.yaml`.

### Error: "failed to get the data key"

**Cause:** Wrong permissions on the key file

**Solution:** Fix permissions:
```bash
chmod 600 ~/.config/sops/age/keys.txt
```

### SOPS doesn't find the key file

**Cause:** Key file is in the wrong location

**Solution:** Verify the file exists:
```bash
ls -la ~/.config/sops/age/keys.txt
```

Should show a file with permissions `-rw-------` (600).

### Different behavior on Trinity vs Neo

**Cause:** One host hasn't been configured yet

**Solution:** Ensure both hosts have completed step 2 (SSH key conversion). Each host needs its own converted key.

## Setting Up a New Host

When adding a new NixOS host:

1. Generate or note the SSH host key's age public key:
   ```bash
   ssh-to-age -i /etc/ssh/ssh_host_ed25519_key.pub
   ```

2. Add the public key to `.sops.yaml`:
   ```yaml
   keys:
     - &trinity_age age1t0n4rl8jjsclpxd6s2tme4ehpcyuqd07u0klpq34sqmvc7dgyatq3483p5
     - &neo_age age1csa9g8m07z3zpplzdrtj63vmcegk7lpyzqytvtkyewx3jk83wcgqmjxs5l
     - &new_host_age age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

   creation_rules:
     - path_regex: secrets/secrets\.yaml$
       key_groups:
         - age:
             - *trinity_age
             - *neo_age
             - *new_host_age
   ```

3. Re-encrypt secrets with new recipient:
   ```bash
   sops updatekeys secrets/secrets.yaml
   ```

4. On the new host, run the conversion steps (step 2 from Initial Setup)

## Security Notes

### Key File Protection

- The key file (`~/.config/sops/age/keys.txt`) must have `600` permissions
- Only the user should be able to read this file
- It contains the private key for decryption

### SSH Host Key

- The SSH host key is the source of the age key
- It's root-owned and located at `/etc/ssh/ssh_host_ed25519_key`
- Conversion requires sudo access
- The SSH host key doesn't change across reboots

### Backup Considerations

The age key can always be regenerated from the SSH host key, so:
- No need to back up `~/.config/sops/age/keys.txt` separately
- DO back up `/etc/ssh/ssh_host_ed25519_key` (part of system backups)
- If you lose the SSH host key, you won't be able to decrypt secrets

## Additional Resources

- [SOPS Documentation](https://github.com/getsops/sops)
- [age Encryption](https://github.com/FiloSottile/age)
- [sops-nix](https://github.com/Mic92/sops-nix)
