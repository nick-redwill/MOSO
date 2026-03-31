
<p align="center">
<img src="media/logo.png" width="300px">
</p>

# Multiboot Operating System Orchestrator

**MOSO** is a command-line tool for creating multiboot USB drives. It handles partitioning, writing, verification, and GRUB configuration automatically — supporting Linux distros, BSD systems Windows, and others.

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
- [ ] Add more supported OSes (specifically Linux distros)
- [ ] Add --list argument for list available systems
- [ ] Add retry logic and special argument for that (--max-retries)

## License

[GPL-3.0](LICENSE)
