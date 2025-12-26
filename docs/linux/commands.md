
# Beginner-friendly Linux commands (with examples)

This file is a small, practical cheat sheet focused on **everyday terminal tasks**.

Conventions used below:
- Replace things in `<angle brackets>` with your own values.
- If a path has spaces, wrap it in quotes: `"My Folder/file.txt"`.

---

## Getting help (very useful)

### See what a command does

```bash
man <command>
```

Example:

```bash
man find
```

### Quick help

```bash
<command> --help
```

---

## Job control: background / foreground / stopping

“Job control” is how you pause a running command, send it to the background, and bring it back.

### Stop (pause) the current program

While a command is running in your terminal, press:

```text
Ctrl+Z
```

This **stops** the process and returns you to a shell prompt.

### List jobs started from this terminal

```bash
jobs
```

You’ll see job numbers like `%1`, `%2`.

### Continue a stopped job in the background

```bash
bg
```

Or for a specific job:

```bash
bg %1
```

### Bring a background job to the foreground

```bash
fg
```

Or for a specific job:

```bash
fg %1
```

### Start something directly in the background

Add `&` at the end:

```bash
sleep 60 &
```

### Keep a process running after you close the terminal

Option A: `nohup` (simple and common)

```bash
nohup <command> > output.log 2>&1 &
```

Example:

```bash
nohup python3 server.py > server.log 2>&1 &
```

Option B: `disown` (after starting something with `&`)

```bash
<command> &
disown
```

### Kill/stop a running program

If it is in the foreground, try:

```text
Ctrl+C
```

If it’s a background job, first list jobs, then kill it:

```bash
jobs
kill %1
```

If you know a PID (process id), you can kill by PID:

```bash
ps aux | grep <name>
kill <pid>
```

---

## Attaching and detaching sessions (tmux / screen)

If you want to **start a long-running task**, detach from it, then re-attach later (even after SSH disconnects), use a terminal “multiplexer” like `tmux` or `screen`.

### tmux (recommended if available)

Install (varies by distro):

```bash
sudo apt install tmux
# or: sudo dnf install tmux
# or: sudo pacman -S tmux
```

Start a new session named `work`:

```bash
tmux new -s work
```

Detach from the session (leave it running):

```text
Ctrl+B, then press D
```

List sessions:

```bash
tmux ls
```

Attach to a session:

```bash
tmux attach -t work
```

Kill a session:

```bash
tmux kill-session -t work
```

### screen (older, but common on servers)

Start a new session:

```bash
screen
```

Detach:

```text
Ctrl+A, then press D
```

List sessions:

```bash
screen -ls
```

Re-attach:

```bash
screen -r
```

If there are multiple sessions:

```bash
screen -r <session_id>
```

---

## Mounting and unmounting drives (Fedora / Workstation)

Most of the time on Fedora Workstation, GNOME will auto-mount removable drives when you plug them in.
If you want to do it from the terminal, the easiest beginner-friendly tool is `udisksctl`.

### Identify the device/partition first

List disks and filesystems:

```bash
lsblk -f
```

Get more details (UUIDs, types):

```bash
sudo blkid
```

Common device names:
- SATA/USB drives: `/dev/sdb`, partitions like `/dev/sdb1`
- NVMe drives: `/dev/nvme0n1`, partitions like `/dev/nvme0n1p1`

### Mount (easy way): `udisksctl`

Mount a partition (example uses `/dev/sdb1`):

```bash
udisksctl mount -b /dev/sdb1
```

It will usually mount under `/run/media/$USER/<label>`.

### Unmount (easy way): `udisksctl`

```bash
udisksctl unmount -b /dev/sdb1
```

### Power off a removable drive (safe removal)

After unmounting, you can power it off (useful for USB drives):

```bash
udisksctl power-off -b /dev/sdb
```

### Mount (manual way): `mount`

1) Create a mount point:

```bash
sudo mkdir -p /mnt/usb
```

2) Mount the partition:

```bash
sudo mount /dev/sdb1 /mnt/usb
```

3) Unmount when done:

```bash
sudo umount /mnt/usb
# or: sudo umount /dev/sdb1
```

Tips:
- If you get “target is busy”, close any terminals or file managers using that folder.
- You can check what’s mounted with: `mount | grep /mnt/usb` or `findmnt /mnt/usb`.

---

## Decrypting and mounting LUKS volumes (Fedora)

Fedora uses LUKS (Linux Unified Key Setup) for full-disk encryption. The usual workflow is:
1) Identify the encrypted partition
2) `luksOpen` (decrypt and create `/dev/mapper/<name>`)
3) Mount the filesystem (or activate LVM, then mount)
4) Unmount and `luksClose`

### 1) Identify the LUKS device

```bash
lsblk -f
```

Look for `crypto_LUKS` in the `FSTYPE` column.

### 2) Open (decrypt) the LUKS container

Example: open `/dev/nvme0n1p3` as `cryptdata`:

```bash
sudo cryptsetup luksOpen /dev/nvme0n1p3 cryptdata
```

You should now have a mapped device:

```bash
ls -l /dev/mapper/cryptdata
lsblk -f
```

Check status:

```bash
sudo cryptsetup status cryptdata
```

### 3A) If the LUKS container contains a normal filesystem

Mount it like this:

```bash
sudo mkdir -p /mnt/cryptdata
sudo mount /dev/mapper/cryptdata /mnt/cryptdata
```

### 3B) If the LUKS container contains LVM (common on Fedora)

After `luksOpen`, activate volume groups:

```bash
sudo vgchange -ay
```

Then list logical volumes and mount the one you want:

```bash
sudo lvs
sudo mkdir -p /mnt/fedora-root
sudo mount /dev/<vg_name>/<lv_name> /mnt/fedora-root
```

If you’re not sure which is which, `lsblk -f` will help show the hierarchy.

### 4) Cleanly unmount and close

Unmount:

```bash
sudo umount /mnt/cryptdata
# (or unmount any LVs you mounted)
```

If you activated LVM and want to deactivate it:

```bash
sudo vgchange -an
```

Close the LUKS mapping:

```bash
sudo cryptsetup luksClose cryptdata
```

### (Danger) Creating/formatting a new LUKS volume

Only for brand new encryption (this will destroy data on the target device):

```bash
sudo cryptsetup luksFormat /dev/sdb1
```


## Finding files: `find` and `locate`

### `find` (search the filesystem live)

Basic pattern:

```bash
find <where_to_search> <tests> <actions>
```

#### Find by name (case-sensitive)

```bash
find . -name "notes.txt"
```

#### Find by name (case-insensitive)

```bash
find . -iname "notes.txt"
```

#### Find files with a wildcard

```bash
find . -name "*.log"
```

#### Find directories only

```bash
find . -type d -name "src"
```

#### Find files only

```bash
find . -type f -name "*.md"
```

#### Find files bigger than 100 MB

```bash
find . -type f -size +100M
```

#### Find files modified in the last 7 days

```bash
find . -type f -mtime -7
```

#### Find and delete (use carefully)

Safer two-step approach:

1) Preview what would match:

```bash
find . -type f -name "*.tmp"
```

2) If it looks correct, delete:

```bash
find . -type f -name "*.tmp" -delete
```

#### Find and run a command on each result

Example: print detailed info for all `.conf` files:

```bash
find /etc -type f -name "*.conf" -exec ls -l {} \;
```

### `locate` (search a database, usually faster)

`locate` is fast because it searches an index (database) rather than walking the disk each time.

Install (varies by distro):

```bash
sudo apt install plocate
# or: sudo apt install mlocate
# or: sudo dnf install mlocate
```

Update the database (might take a moment):

```bash
sudo updatedb
```

Search for a filename anywhere:

```bash
locate notes.txt
```

Case-insensitive search:

```bash
locate -i notes.txt
```

Show only up to 20 results:

```bash
locate -n 20 notes
```

If `locate` shows old paths, run `sudo updatedb` again (the index can be out of date).

