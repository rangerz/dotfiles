# Ubuntu

## manpath: can't set the locale; make sure $LC_* and $LANG are correct

```bash
sudo apt-get update
sudo apt-get install locales -y
sudo locale-gen en_US.UTF-8
sudo update-locale LANG=en_US.UTF-8
```

## sudo Password

```bash
# Enable passwordless sudo
sudo visudo
# Add this line at the end:
# %sudo ALL=(ALL:ALL) NOPASSWD:ALL
# to overwrite
# %sudo ALL=(ALL:ALL)
```
