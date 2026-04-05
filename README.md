<p align="center">
<img src="media/logo.png" width="300px">
</p>

# Multiboot Operating System Orchestrator

**MOSO** is a command-line tool for creating multiboot USB drives. It automates partitioning, image writing, verification, and GRUB configuration, with support for Linux distributions, BSD systems, Windows, and more.

## Features

- Automatic partitioning, formatting, and device preparation
- GRUB installation and dynamic configuration generation
- Integrity verification via checksums
- Support for Linux, Windows, BSD and other systems
- BIOS and UEFI boot mode support
- Modular architecture for easy extension and customization

## Design Principles

#### **Simplicity & Transparency**

MOSO is a 100% shell-based tool and does **not** include any precompiled binaries or executables. It relies on simple, reliable, open-source utilities and straightforward methods for writing and booting installation ISOs.
When third-party tools are required, MOSO explicitly prompts the user before using them ensuring full control remains in **your** hands.

#### **Ease of Use**

A single command is enough to create a fully functional multiboot USB drive, with images written, configured, and verified automatically.

#### **Security**

By default, MOSO verifies checksums after writing images (unless explicitly disabled).
Destructive actions always require user confirmation, unless the `--force` flag is used.

#### **Modularity & Scalability**

MOSO is designed with modularity, reusability, and scalability in mind. This makes it easier to add new systems, extend functionality, and customize behavior without unnecessary complexity.

## Installation

```bash
git clone https://github.com/nick-redwill/moso
cd moso
chmod +x moso.sh
```

## Usage

```bash
./moso.sh [OPTIONS] <device>

Options:
  --iso <system:/path>     ISO to install, repeatable
  --force                  Skip confirmation prompt (not recommended)
  --no-verify              Skip write verification (not recommended)
  --help                   Show help
```

### Examples

```bash
# Single system
./moso.sh --iso mint:/path/to/mint.iso /dev/sdb

# Multiple systems
./moso.sh \
  --iso mint:/path/to/linuxmint.iso \
  --iso debian:/path/to/debian.iso \
  --iso windows-10:/path/to/win10.iso \
  /dev/sdb

# Skipping confirmation (for scripting)
./moso.sh --force --iso arch:/path/to/arch.iso /dev/sdb

# Skipping verification
./moso.sh --no-verify --iso ubuntu:/path/to/ubuntu.iso /dev/sdb
```

## Supported ISOs

| Family    | Version / Distribution                                                                                                                                                                                                                                                                                                                                                            | Boot Mode   | Status         | Notes                                                                                       |
| --------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------- | -------------- | ------------------------------------------------------------------------------------------- |
| GNU/Linux | **Debian-based:** Ubuntu, Linux Mint, Debian, Pop!_OS, Kali<br />**Arch-based:** Arch Linux, Manjaro, Artix, CachyOS<br />**Red Hat-based:** Fedora (incl. Silverblue/Kinoite/Bazzite), AlmaLinux, Rocky Linux <br />**Independent:** Alpine, Void, NixOS, OpenSUSE Leap<br />**Live tools:** GParted, SystemRescue, Puppy (Void & Debian editions) | BIOS & UEFI | ✅ Supported   | Uses built-in `grub.cfg`. <br />Persistence is **not supported**.                   |
| GNU/Linux | **Arch-based:** EndeavourOS                                                                                                                                                                                                                                                                                                                                                 | BIOS & UEFI | ✅ Supported   | Uses direct kernel/initramfs loading with native parameters (no GRUB).                      |
| Windows   | Windows 8, 8.1, 10, 11                                                                                                                                                                                                                                                                                                                                                            | UEFI only   | ✅ Supported   | Optional BIOS support and Windows 7 planned via[`wimboot`](https://github.com/ipxe/wimboot). |
| BSD       | FreeBSD                                                                                                                                                                                                                                                                                                                                                                           | BIOS & UEFI | ✅ Supported   | Uses chainloading with the native bootloader.                                               |
| BSD       | NetBSD, OpenBSD                                                                                                                                                                                                                                                                                                                                                                           | —          | ❌ Unsupported | No idea how to make it work yet. Contributions or ideas are welcome.                        |
| Solaris   | Solaris 11                                                                                                                                                                                                                                                                                                                                                                        | UEFI only   | 🧪 Untested    | Needs more testing. BIOS support uncertain.                                                 |

## Limitations & Caveats ⚠️

* **Secure Boot is not supported** `<br>`
  MOSO uses a standard GRUB setup and does not include signed bootloaders.
* **Drives are formatted using GPT** `<br>`
  Some older systems with limited or no GPT support may fail to boot. MBR support may be considered in the future.
* **MOSO performs destructive operations** `<br>`
  Always double-check the selected device and ensure all important data is backed up before proceeding.
* **UEFI support is more reliable than BIOS** `<br>`
  Some systems (especially Windows) may not boot or function correctly in legacy BIOS mode.
* **Persistence is not supported** `<br>`
  Live systems will not retain changes across reboots.
* **ISO compatibility may vary** `<br>`
  Certain distributions or ISO versions may not work as expected. Please report any issues you encounter.

## TODO

- [ ] Add support for more OSes (specifically Linux distros)
- [ ] Either add a better support for Legacy BIOS mode for certain OSes or remove it completely and stick to UEFI-only
- [ ] Add `--list` flag for listing all available systems
- [ ] Add retry logic and special argument for that (`--max-retries=<N>`)

## Contributing & Compatibility Reports

If you’ve successfully tested MOSO with a system that isn’t listed here, feel free to open a PR or share your results.

Found a bug or something not working as expected? Please open an issue and include:

- ISO name and version
- Boot mode (BIOS/UEFI)
- What happened vs what you expected

Even partial reports make improving compatibility much easier.

## License

[GPL-3.0](LICENSE)
