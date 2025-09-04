# wsl-ubuntu

## manpath: can't set the locale; make sure $LC_* and $LANG are correct

```bash
sudo apt-get update
sudo apt-get install locales -y
sudo locale-gen en_US.UTF-8
sudo update-locale LANG=en_US.UTF-8
```

## sudo Password

```bash
echo "ranger ALL=(ALL:ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/ranger
```
