# Installation guide — SIFT Workstation + Autopsy 4.x
### Preparation for class 2 · Digital Forensics

---

## Summary

You will install **SIFT Workstation** (SANS's forensic toolset) on a clean **Ubuntu 22.04 Desktop**, and then manually install **Autopsy 4.x** (the current graphical version, instead of the legacy 2.x that comes standard in Linux distributions — 2.x has known bugs and is no longer recommended).

**Estimated time:** 60–90 minutes (depends on internet speed).

**Machine requirements:**
- Virtual machine (VirtualBox, VMware or similar) or dedicated machine
- At least 4 GB RAM, 40 GB of free disk space
- Stable internet connection - be careful when using eduroam

---

## Step 1 — Installing the base: Ubuntu 22.04 Desktop

1. Download the official image: https://releases.ubuntu.com/22.04/ (select **Desktop image**, not Server).
2. Create a new VM (2+ CPUs, 4+ GB RAM, 40+ GB disk) and install Ubuntu normally..
3. After installation, update the system **before continuing**::

```bash
sudo apt update
sudo apt upgrade -y
sudo reboot
```

> ⚠️ Stay on version 22.04. Do not upgrade to 24.04 — SIFT/SaltStack is tested and maintained for 22.04, for now.

> 💡 **Note:** It is also recommended to install the Guest Addons package, or the equivalent for other virtualization environments, which will allow you to use the clipboard and shared folder features.

---

## Step 2 — Installing SIFT Workstation (via Cast)

The current official installer is called **Cast** (it replaced the old `sift-cli`).

```bash
# Confirm the latest version at:
# https://github.com/ekristen/cast/releases

wget https://github.com/ekristen/cast/releases/download/v0.14.30/cast-v0.14.30-linux-amd64.deb
sudo dpkg -i cast-v0.14.30-linux-amd64.deb

sudo cast install --mode=desktop teamdfir/sift-saltstack
```

This step takes quite a while (downloading and installing dozens of forensic tools). Take a break.

After finishing:
```bash
sudo reboot
```

---

## Step 3 — Replacing Autopsy 2.x with Autopsy 4.x

By default, SIFT installs **Autopsy 2.24**, which is a legacy version (web interface via Perl) with known "taint mode" bugs (errors such as `Unsafe directory in $ENV{PATH}`). We will install version **4.x**, which is a modern, more stable, and complete desktop application.

### 3.1 — Install prerequisites

```bash
curl -fsSL https://github.com/sleuthkit/autopsy/raw/refs/heads/develop/linux_macos_install_scripts/install_prereqs_ubuntu.sh | bash
sudo apt --fix-broken install --yes
```

### 3.2 — Resolve library conflict (critical)

SIFT already includes a PPA (`gift/stable`) with newer versions of `libewf`, `libvhdi`, and `libvmdk`, but Ubuntu also has older versions of these libraries in its standard repositories, with **different names** (e.g., `libewf2` vs. `libewf`). This causes conflicts. Resolve them in the correct order:

```bash
# Remove any older (universe) versions, if they are installed.
sudo apt remove -y libewf2 libvhdi1 libvmdk1

# Install the PPA gift versions (runtime + dev)
sudo apt install -y \
  libewf libewf-dev \
  libvhdi libvhdi-dev \
  libvmdk libvmdk-dev

# Confirm that the PPA versions have been installed.
apt policy libewf libvhdi libvmdk
```

All versions must display `Installed:` with a version ending in `...ppa1~jammy`.

### 3.3 — Installing the Sleuth Kit Java bindings

```bash
cd ~
wget https://github.com/sleuthkit/sleuthkit/releases/download/sleuthkit-4.14.0/sleuthkit-java_4.14.0-1_amd64.deb
sudo dpkg -i --force-depends --force-overwrite sleuthkit-java_4.14.0-1_amd64.deb
```

> 💡 ** Note: ** the official `.deb` expects old dependency names (`libewf2`, etc.) that do not exist when using the `gift` PPA. Actual libraries are present (just the name is different), so it's safe to use `--force-depends` here.

Confirm:
```bash
dpkg -l | grep sleuthkit-java
```
It must display `ii` at the beginning of the line.

**Locks the package immediately** — because it was forcibly installed (`--force-depends`), `apt` may interpret it as "orphaned" and automatically remove it at the next cleanup operation (for example, when removing Autopsy 2. x in step 3.6). This avoids this problem:

```bash
sudo apt-mark hold sleuthkit-java
```

### 3.4 — Install Autopsy 4.22.1

> We use version **4.22.1** (not the latest version available) because it is confirmed to be compatible with Sleuth Kit 4.14.0 and Java 17. Newer versions (4.23.x) have known bugs related to incompatibility with Java 17.

```bash
cd ~
wget https://github.com/sleuthkit/autopsy/releases/download/autopsy-4.22.1/autopsy-4.22.1_v2.zip
wget https://raw.githubusercontent.com/sleuthkit/autopsy/develop/linux_macos_install_scripts/install_application.sh
chmod +x install_application.sh

# Confirm the path to JDK 17 already installed:
ls /usr/lib/jvm/
# Usually it is: /usr/lib/jvm/java-1.17.0-openjdk-amd64

sudo ./install_application.sh \
  -z ~/autopsy-4.22.1_v2.zip \
  -i ~/autopsy \
  -j /usr/lib/jvm/java-1.17.0-openjdk-amd64
```

### 3.5 — Correcting permissions before opening Autopsy for the first time (critical)

Since the installation was done with `sudo`, the entire `~/autopsy` tree (including `autopsy/solr/server`) is owned by `root`. This prevents the **embedded Solr** — used by the Keyword Search module — from creating its logs folder and initializing. Correct this **before** opening the application and creating your first case:

```bash
sudo chown -R $USER:$USER ~/autopsy
```

> **Why this step cannot be skipped:** If you open a case and add a data source before correcting this, the symptom isn't an obvious error—it's a discreet popup **"Solr Keyword Search Service Error: Failed to open or create core"** (easy to ignore) and the **file tree remains empty**, even with the image correctly added and intact. The ingest simply fails halfway through without clear warning. If this has happened to you: correct the permissions above and then **remove the data source from the case and add it again**—reopening the case isn't enough; the ingest must run from scratch with Solr already functional.

**Optional quick test, to confirm that Solr boots on its own before testing Autopsy:**
```bash
~/autopsy/autopsy-4.22.1/autopsy/solr/bin/solr start
# Deve terminar com: "Started Solr server on port 8983"
~/autopsy/autopsy-4.22.1/autopsy/solr/bin/solr stop
```

### 3.6 — Testing

```bash
cd ~/autopsy/autopsy-4.22.1/bin
./autopsy
```

You should open a **desktop application window** (not a browser) after 20–40 seconds. Messages/warnings in the terminal are normal, as long as they are not fatal errors. It's also normal for a small red circle to appear in the lower right corner during startup, indicating a `ConcurrentModificationException` related to the interface theme (`setUIFont`) — this is a known cosmetic bug in Autopsy 4.x, with no functional impact; you can ignore it.

Alternatively, you can use the desktop shortcut, of course — but you lose the ability to observe the startup in detail.

### 3.7 — Remove the old Autopsy 2.x (optional, but recommended)

> ⚠️ **Warning:** This removal may remove the `sleuthkit-java` along, even if you have already performed `apt-mark hold` in step 3.3 — confirm immediately after removal.

```bash
sudo apt remove --purge autopsy
```

**Immediately confirm that sleuthkit-java survived:**

```bash
dpkg -l | grep sleuthkit-java
```

If nothing appears, reinstall:

```bash
sudo dpkg -i --force-depends --force-overwrite ~/sleuthkit-java_4.14.0-1_amd64.deb
sudo ldconfig
sudo apt-mark hold sleuthkit-java
```

And test `./autopsy` again before proceeding (the symptom of having missed it is a `Fatal Error! Problem with Sleuth Kit JNI` error mentioning `libtsk.so.23: unable to open shared object file`).

---

## Note: Do not install `sleuthkit` (command-line tools) via apt.

If you need Sleuth Kit CLI tools (`mmls`, `fsstat`, `fls`, `icat`, etc.) for manual diagnostics, **do not run `sudo apt install sleuthkit`** — the package from the repository depends on `libtsk19` from another PPA (`sift`), which is incompatible with the `gift` PPA libraries we installed for Autopsy 4.x. This generates the same type of dependency conflict already resolved in section 3.2, and `apt --fix-broken install` may attempt to remove `sleuthkit-java` to "resolve" the conflict. The official Sleuth Kit itself does not publish a standalone `.deb` of these tools on GitHub (only `sleuthkit-java`), so there is no "right package" to download directly.

**Clean solution: compile from source code.** Since you already have `libewf-dev`, `libvhdi-dev`, and `libvmdk-dev` installed (section 3.2), the compilation installs the binaries in `/usr/local/bin`, outside the `apt`/`dpkg` system—it does not interfere with any already resolved dependencies.

```bash
sudo apt install -y build-essential autoconf libtool git pkg-config
```

> 💡 **Note:** It's normal to see the warning `sleuthkit-java : Depends: libewf2 ... but it is not going to be installed` followed by `E: Unmet dependencies` here (and in any other future `apt install`). This is just `apt` reminding you of the held state of `sleuthkit-java`, configured intentionally in section 3.3 — the requested packages are normally installed below this warning (confirm that `... is already the newest version` or `Setting up ...` appears for each one). It's not a new error and doesn't prevent anything.

```bash
cd ~
wget https://github.com/sleuthkit/sleuthkit/releases/download/sleuthkit-4.14.0/sleuthkit-4.14.0.tar.gz
tar xzf sleuthkit-4.14.0.tar.gz
cd sleuthkit-4.14.0

./configure --disable-java
make -j$(nproc)
sudo make install
sudo ldconfig
```

Confirm:
```bash
which mmls fls fsstat icat
mmls /caminho/para/imagem.raw
fsstat -o 63 /caminho/para/imagem.raw
```

**Faster alternative (without compiling), just to quickly confirm if an image is intact and readable:** SIFT already comes with `pytsk3` pre-installed (Sleuth Kit Python bindings, no extra system dependencies):

```bash
python3 << 'EOF'
import pytsk3

img = pytsk3.Img_Info('/path/to/imagem.raw')
vol = pytsk3.Volume_Info(img)
for part in vol:
    print(part.addr, part.desc, part.start, part.len)

# adjust the offset (in sectors) according to the partition you want to inspect
fs = pytsk3.FS_Info(img, offset=63*512)
root = fs.open_dir(path="/")
for entry in root:
    print(entry.info.name.name)
EOF
```

---

## Next steps

After completing the installation:

1. Follow the [Environment Validation Guide](validation.md) to verify that
   the DFIR Lab is correctly configured.
2. If you encounter any problems, consult the
   [Troubleshooting Guide](troubleshooting.md).
