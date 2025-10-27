# Start9 Pure: Move Bitcoin Data to an Additional Drive

Set up a new additional drive (1TB+, 100% wiped!) as dedicated storage for your Bitcoin node on Start9 Pure.

---

## ⚠️ WARNING

- **ALL DATA ON THE TARGET SSD WILL BE ERASED.**
- Confirm the correct disk using `lsblk`.
- This guide assumes your SSD is `/dev/sda`. Adjust if needed.

---

## 1. Initial SSD Preparation
```sh
sudo -i
lsblk                             # Confirm SSD (e.g. /dev/sda)
fdisk /dev/sda                    # Partition: 'g', 'n', ENTER, ENTER, ENTER, 'w'
mkfs.ext4 /dev/sda1               # Format as ext4
mkdir -p /mnt/bitcoin-ssd
mount /dev/sda1 /mnt/bitcoin-ssd
touch /mnt/bitcoin-ssd/x-ssd      # Mark for easy identification
```

---

## 2. Stop the Bitcoin Service

- Use the StartOS UI to fully **stop** the Bitcoin service before copying data.

---

## 3. Copy Bitcoin Data to SSD, Backup Old Data

```sh
# Copy blocks, chainstate, and indexes directories to SSD
rsync -av --progress /embassy-data/package-data/volumes/bitcoind/data/main/blocks /mnt/bitcoin-ssd/
rsync -av --progress /embassy-data/package-data/volumes/bitcoind/data/main/chainstate /mnt/bitcoin-ssd/
rsync -av --progress /embassy-data/package-data/volumes/bitcoind/data/main/indexes /mnt/bitcoin-ssd/

# Verify copied data
ls -la /mnt/bitcoin-ssd           # Should show blocks, chainstate, indexes, and x-ssd marker
sudo ls /mnt/bitcoin-ssd/blocks   # Check blocks directory content

# Backup original data
mv /embassy-data/package-data/volumes/bitcoind/data/main/blocks /embassy-data/package-data/volumes/bitcoind/data/main/blocks.backup
mv /embassy-data/package-data/volumes/bitcoind/data/main/chainstate /embassy-data/package-data/volumes/bitcoind/data/main/chainstate.backup
mv /embassy-data/package-data/volumes/bitcoind/data/main/indexes /embassy-data/package-data/volumes/bitcoind/data/main/indexes.backup
```

---

## 4. Set up fstab for Automatic Mounting (**chroot environment!**)

**Enter chroot upgrade environment:**
```sh
sudo /usr/lib/startos/scripts/chroot-and-upgrade
```

Identify your drive using `blkid`:
```sh
blkid /dev/sda1
```

- Edit `/etc/fstab` and **add** (replace UUID):
  ```
  UUID=<uuid-here> /mnt/bitcoin-ssd ext4 defaults,noatime,nofail 0 2
  ```

---

## 5. Create Bind-Mount Script and Service

### Create the script:
```sh
nano /usr/local/bin/mount-bitcoinssd.sh
```
Paste:
```sh
#!/bin/bash
set -e

DATA_DIR="/embassy-data/package-data/volumes/bitcoind/data/main"
SSD_DIR="/mnt/bitcoin-ssd"
SUBDIRS=("blocks" "chainstate" "indexes")

# Function to check if directory exists and is empty
is_empty_dir() {
    [[ -d "$1" && -z "$(ls -A "$1")" ]]
}

# Function to mount a subdirectory
mount_subdir() {
    local subdir="$1"
    local target="$DATA_DIR/$subdir"
    local source="$SSD_DIR/$subdir"

    # Ensure source directory exists
    mkdir -p "$source"

    # Mount the subdirectory
    mount --bind "$source" "$target"
    echo "Mounted $source to $target"
}

# Wait for all subdirectories to exist and be empty
for i in {1..30}; do
    all_ready=true

    for subdir in "${SUBDIRS[@]}"; do
        if ! is_empty_dir "$DATA_DIR/$subdir"; then
            all_ready=false
            break
        fi
    done

    if $all_ready; then
        # Mount all subdirectories
        for subdir in "${SUBDIRS[@]}"; do
            mount_subdir "$subdir"
        done
        exit 0
    fi

    sleep 2
done

echo "Timeout: Directories not ready after 60 seconds"
exit 1
```
Then:
```sh
chmod +x /usr/local/bin/mount-bitcoinssd.sh
```

### Create the systemd unit:
```sh
nano /etc/systemd/system/bitcoinssd-bindmount.service
```
Paste:
```ini
[Unit]
Description=Bind mount bitcoin SSD subdirectories (overlay/race-stable)
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
```sh
systemctl enable bitcoinssd-bindmount
```

- **Exit chroot with:** `exit` (the server will auto-reboot).

---

## 6. Post-Reboot Verification

```sh
# Check that subdirectories are properly mounted
sudo ls /embassy-data/package-data/volumes/bitcoind/data/main/blocks
sudo ls /embassy-data/package-data/volumes/bitcoind/data/main/chainstate
sudo ls /embassy-data/package-data/volumes/bitcoind/data/main/indexes

# Verify mount points
mount | grep bitcoin
# Should show three separate bind mounts for blocks, chainstate, and indexes
```
Start Bitcoin service from StartOS UI, verify sync/operation.

---

## 7. Final Clean-Up (when 100% sure)

```sh
sudo rm -rf /embassy-data/package-data/volumes/bitcoind/data/main/*.backup
```

---

## TL;DR Checklist

1. As `sudo -i`: Partition, format, mount, copy blocks/chainstate/indexes subdirectories, backup.
2. As chroot upgrade: Edit `/etc/fstab`, create bind-mount script & systemd unit, enable, exit chroot (triggers auto-reboot).
3. After reboot: verify three separate mounts, start Bitcoin service, clean up old data.

---

## Key Differences from Previous Version

- **Granular mounting:** Now mounts `blocks`, `chainstate`, and `indexes` directories individually instead of the entire data directory
- **Better isolation:** Each Bitcoin Core database component is mounted separately, allowing for future flexibility
- **Improved reliability:** Atomic check ensures all three directories are ready before any mounts occur

---

**Result:**  
Fully automatic, overlay-stable Bitcoin node running from a dedicated SSD with optimized subdirectory mounting!
