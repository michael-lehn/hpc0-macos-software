## HPC0 macOS Software Setup

This repository installs the software required for the HPC0 (Introduction to High Performance Computing) course on macOS.

---

## Prerequisites

This setup requires Homebrew.

If you do not have Homebrew installed, open a terminal and run:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

During installation, you may be prompted to install the Xcode Command Line Tools.  
Please follow the instructions in the popup.

---

## Usage (for the impatient)

Open a terminal, copy the following line, paste it into the terminal, and press Enter:

```bash
brew install git && ( [ -d hpc0-macos/.git ] && cd hpc0-macos && git pull && ./install.sh || git clone https://github.com/michael-lehn/hpc0-macos-software.git && cd hpc0-macos && ./install.sh)
```
