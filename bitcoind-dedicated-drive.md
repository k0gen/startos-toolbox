# Start9 Pure: Move Bitcoin Data to an Additional Drive

Set up a new additional drive (1TB+, 100% wiped!) as dedicated storage for your Bitcoin node on Start9 Pure.

---

## ⚠️ WARNING

- **ALL DATA ON THE TARGET SSD WILL BE ERASED.**
- Confirm the correct disk using `lsblk`.
- This guide assumes your SSD is `/dev/sda`. Adjust if needed.

---

## 1. Initial SSD Preparation
```
sudo -i
lsblk                             # Confirm SSD (e.g. /dev/sda)
fdisk /dev/sda                    # Partition: 'g', 'n', ENTER, ENTER, ENTER, 'w'
mkfs.ext4 /dev/sda1               # Format as ext4
mkdir -p /mnt/bitcoin-ssd
mount /dev/sda1 /mnt/bitcoin-ssd
touch /mnt/bitcoin-ssd/1-ssd      # Mark for easy identification
```

---

## 2. Stop the Bitcoin Service

- Use the StartOS UI to fully **stop** the Bitcoin service before copying data.

---

## 3. Copy Bitcoin Data to SSD, Backup Old Data

```
rsync -av --progress /embassy-data/package-data/volumes/bitcoind/data/main/ /mnt/bitcoin-ssd/
ls /mnt/bitcoin-ssd
ls /mnt/bitcoin-ssd/blocks        # Check content + '1-ssd' marker

mv /embassy-data/package-data/volumes/bitcoind/data/main /embassy-data/package-data/volumes/bitcoind/data/main.backup
```

---

## 4. Set up fstab for Automatic Mounting (**chroot environment!**)

**Enter chroot upgrade environment:**
```
sudo /usr/lib/startos/scripts/chroot-and-upgrade
```

Identify your drive using `blkid`:
```
blkid /dev/sda1
```

- Edit `/etc/fstab` and **add** (replace UUID):
  ```
  UUID=<uuid-here> /mnt/bitcoin-ssd ext4 defaults,noatime,nofail 0 2
  ```

---

## 5. Create Bind-Mount Script and Service

### Create the script:
```
nano /usr/local/bin/mount-bitcoinssd.sh
```
Paste:
```
#!/bin/bash
set -e

DATA_DIR="/embassy-data/package-data/volumes/bitcoind/data/main"

# Wait for empty directory and mount
for i in {1..30}; do
    [[ -d "$DATA_DIR" && -z "$(ls -A "$DATA_DIR")" ]] && {
        mount --bind /mnt/bitcoin-ssd "$DATA_DIR"
        exit 0
    }
    sleep 2
done
exit 1
```
Then:
```
chmod +x /usr/local/bin/mount-bitcoinssd.sh
```

### Create the systemd unit:
```
nano /etc/systemd/system/bitcoinssd-bindmount.service
```
Paste:
```
[Unit]
Description=Bind mount bitcoin SSD (overlay/race-stable)
Wants=podman.service
After=podman.service

[Service]
Type=simple
Restart=always
RestartSec=3
ExecStart=/usr/local/bin/mount-bitcoinssd.sh

[Install]
WantedBy=multi-user.target
```
Enable the service:
```
systemctl enable bitcoinssd-bindmount
```

- **Exit chroot with:** `exit` (the server will auto-reboot).

---

## 6. Post-Reboot Verification

```
ls /embassy-data/package-data/volumes/bitcoind/data/main
# Should list all your Bitcoin files, including '1-ssd'
# Start Bitcoin service from StartOS UI, verify sync/operation.
```

---

## 7. Final Clean-Up (when 100% sure)

```
sudo rm -rf /embassy-data/package-data/volumes/bitcoind/data/main.backup
```

---

## TL;DR Checklist

1. As `sudo -i`: Partition, format, mount, copy and backup.
2. As chroot upgrade: Edit `/etc/fstab`, create bind-mount script & systemd unit, enable, exit chroot (triggers auto-reboot).
3. After reboot: verify, clean up old data.

---

**Result:**  
Fully automatic, overlay-stable Bitcoin node running from a dedicated SSD!
