<p align="center">
<img src="media/logo.png" width="300px">
</p>

# Multiboot Operating System Orchestrator

**MOSO** is a command-line tool for creating multiboot USB drives. It automates partitioning, image writing, verification, and GRUB configuration, with support for Linux distributions, BSD systems, Windows, and more.

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

## TODO

- [ ] Write a better README lol
- [ ] Add support for more OSes (specifically Linux distros)
- [ ] Either add a better support for Legacy BIOS mode for certain OSes or remove it completely and stick to UEFI-only
- [ ] Add `--list` flag for listing all available systems
- [ ] Add retry logic and special argument for that (`--max-retries=<N>`)

## License

[GPL-3.0](LICENSE)
