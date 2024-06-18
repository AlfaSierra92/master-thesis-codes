## iPerf w/ AC
A customized iPerf with Access Categories (BK, BE, VI, VO).
Currently extremely work in progress.
Because patch file comes from a different iPerf version, it must be applied manually (but in this case is already applied).

## Rock3a tweaking
### Rock3a ath9k debug mode

```bash
git clone --depth=1 --branch=main https://github.com/armbian/build 

cd build/

vim config/kernel/linux-rockchip64-current.config 
```

edit config file by adding:

```bash
CONFIG_ATH9K_HTC_DEBUGFS=y
CONFIG_ATH9K_HWRNG=y
CONFIG_ATH9K_DEBUGFS=y
```

### Enable queues

```bash
cd ~/build/patch/kernel/archive/rockchip64-6.6

cp "Armbian patch"/00550-ac.patch .
```

### Kernel building
Compile just the kernel with:

```bash
./compile.sh kernel ARTIFACT_IGNORE_CACHE='yes' BOARD=rock-3a BRANCH=current
```

After a long time, copy the *.deb files found in *output/deb* into rock and installing by *dpkg -i *.deb* (can be necessary, after, to launch *apt install -f* to fix possibily missing dependences).