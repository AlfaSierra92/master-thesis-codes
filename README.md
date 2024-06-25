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

### More useful stats
```bash
cd ~/build/patch/kernel/archive/rockchip64-6.6

cp "Armbian patch"/00551-ac.patch .
```

N.b.:
Then, you have to multiplicate *cc->cycles* with *div = common->clockrate * 1000* if needed:
```c
if (cc->cycles > 0) ret = cc->rx_busy * 100 / cc->cycles;
```
Look [here](https://github.com/torvalds/linux/blob/50736169ecc8387247fe6a00932852ce7b057083/drivers/net/wireless/ath/ath9k/link.c#L506).

### Kernel building
Compile just the kernel with:

```bash
./compile.sh kernel ARTIFACT_IGNORE_CACHE='yes' BOARD=rock-3a BRANCH=current
```

After a long time, copy the *.deb files found in *output/deb* into rock and installing by *dpkg -i *.deb* (can be necessary, after, to launch *apt install -f* to fix possibily missing dependences).

## Setting rock-3a Wi-Fi interface
```bash
sleep 15

ip link set dev wlp1s0 down
# imposta la tipologia come ad-hoc
iw wlp1s0 set type ocb
# accende l'interfaccia
ip link set dev wlp1s0 up

iw wlp1s0 ocb join 2462 10MHz
ip addr add 192.168.100.26/24 dev wlp1s0
ip route add default via 192.168.100.26 dev wlp1s0
```

### Setting an IEEE 802.11p physical data rate/modulation

Normally, the user can set the physical data rate by leveraging the `iw` tool, and specifying:
```
iw dev wlan0 set bitrates legacy-5 <double of the desired bitrate value in Mbit/s>
```
This is also the procedure implemented in `iw_startup` to set an initial data rate to 3 Mbit/s, and this command can also be used in standard OpenWrt installations to set a desidered data rate with, for instance, other 802.11n or 802.11ac cards.

Unfortunately, we found out that this is not always possible with 802.11p and OCB mode, at least for certain desidered physical data rates, due to `iw` returning "Invalid argument (-22)" errors.
These errors, and thus the selectable physical data rates, seem also to be dependant on the actual hardware and chipset revision, and on how it "reacts" after the physical data rate change request.

Concerning the DHXA-222 cards, `iw dev wlan0 set bitrates legacy-5` lets the user select any of the mandatory physical data rates for IEEE 802.11p, as specified in IEEE 802.11-2020, i.e., either 3 Mbit/s (`iw dev wlan0 set bitrates legacy-5 6`), or 6 Mbit/s (`iw dev wlan0 set bitrates legacy-5 12`), or 12 Mbit/s (`iw dev wlan0 set bitrates legacy-5 24`).

With other cards, however, this is not always guaranteed to work. If it happens that you card does not let you select at least the mandatory rates, you should be able to rely on a workaround, which involves forcing a fixed data rate index in the Minstrel rate adapation algorithm used by Linux.

You can set a desired fixed data rate with:
```
echo <index> > /sys/kernel/debug/ieee80211/phy0/rc/fixed_rate_idx
```

Finding the right indeces for the IEEE 802.11p rates may require a bit of work (the values are not so well documented, and may also be driver dependant - we are, however, investigating this point!). The following are some values we found, with the corresponding IEEE 802.11p data rates, for some AR9642-based mPCIe cards we tested (i.e., Atheros AR5B22):
```
  |INDEX|  -> |PHYS. DATA RATE|
4294967288 ->     3 Mbit/s
4294967289 ->   4.5 Mbit/s
4294967290 ->     6 Mbit/s
4294967291 ->     9 Mbit/s
4294967292 ->    12 Mbit/s
4294967293 ->    18 Mbit/s
4294967294 ->    24 Mbit/s
```


## Tests
Be aware! To use `-q 0` parameter you must install *netcat-openbsd* instead of netcat-traditional (this one lacks it).
### Test 1
Server:
```bash
iperf -s -u -i 1
```

Client (VO - VI - BK)
```bash
iperf -c 224.0.67.67 -t 600 -u -b 10m -A VI
```

### Test 2
Nodes:
```bash
./"Test Scripts"/on_your_marks.sh 1 5 350
```

Start:
```bash
./"Test Scripts"/go.sh
```