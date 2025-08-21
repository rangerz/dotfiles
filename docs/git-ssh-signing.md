# Setup SSH for Git commit signing

```bash
# Requirement: Git >= 2.34
git --version

# Generate SSH key (if you don't have one yet)
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519 -C "your@email.com"

# Export public key
cat ~/.ssh/id_ed25519.pub

# Upload to GitHub / GitLab
# - Add as "SSH key" (for push/pull)
# - Add as "Signing key" (for commit/tag verification)
```

## Git Config

```bash
# Enable SSH commit signing
git config --global gpg.format ssh

# Use your SSH public key as signing key
git config --global user.signingKey ~/.ssh/id_ed25519.pub

# Always sign commits and tags
git config --global commit.gpgsign true
git config --global tag.gpgSign true
```

## Allowed signers file (for verification)

```bash
# Create allowed signers list
mkdir -p ~/.config/git
echo "your@email.com $(cat ~/.ssh/id_ed25519.pub)" > ~/.config/git/allowed_signers

# Tell Git where to find it
git config --global gpg.ssh.allowedSignersFile ~/.config/git/allowed_signers
```

## Test commit signing

```bash
# Make a signed commit
git commit -S -m "test SSH signing"

# Show signature
git log --show-signature -1

# Verify commit explicitly
git verify-commit HEAD
```
