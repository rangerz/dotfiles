# Setup GPG fot Git commit

```bash
# Install gpg tool
brew install gnupg
sudo apt install -y gpa seahorse

# Put in ~/.zshrc
export GPG_TTY=$(tty)

# Gen GPG key
gpg --full-generate-key
# (1) RSA and RSA (default)
# 4096 keysize
# 0 = key does not expire
# y correct
# Real Name: <YOUR_NAME>
# Email address: <YOUR@EMAIL>
# Passphrase: (empty)

# Show GPG key ID
gpg --list-secret-keys --keyid-format LONG
# [keyboxd]
# ---------
# sec   rsa4096/BE21BD659BB8103D 2024-12-21 [SC]
#       <YOUR GPG KEY ID>
# uid                 [ultimate] <YOUR_NAME> <YOUR@EMAIL>
# ssb   rsa4096/439C6B01C406DF04 2024-12-21 [E]

# Export GPG Key to public-key.txt and private-key.txt
cd ~/.gnupg
gpg --armor --output public-key.txt --export <YOUR GPG KEY ID>
gpg --armor --output private-key.txt --export-secret-keys

# Setup to github.com
cat public-key.txt

# git config
git config --global commit.gpgSign true
git config --global user.signingkey <YOUR GPG KEY ID>

# Git commit with signature (-S)
git commit -S -m "git commit"

# Show GPG for git log
git log --show-signature
```
