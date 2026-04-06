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

## What will be installed

This script installs the main software and tools used in the HPC0 course:

- `git`, GNU `make`, the GNU C/C++ compiler, and the LLVM toolchain (including
  libraries)
- The ABC compiler and the ULM generator
- `iTerm2` (unless it's already installed), which I consider the best terminal emulator on macOS

In addition, the system is configured to some extent according to my personal
preferences (which you are not required to share). Details on how to undo these
changes are given below. For now, here is what is modified:

- `ls` is aliased to `eza` to provide a more colorful and informative output
- `make` is aliased to `gmake`
- `vim` is aliased to `nvim` (Neovim), as I consider it the better Vim
- `nvim` is installed along with my configuration and a set of plugins I find useful  
  (your existing Neovim configuration will not be overwritten; a backup is created)
- Nerd Fonts are installed so that file icons and symbols display correctly in Neovim

### If you do not like these changes

- All modifications to `~/.bash_profile` are marked with the comment `HPC0`  
  → you can remove these lines at any time
- If you want to restore your previous Neovim configuration:  
  a backup has been created in `~/.config` with a name like  
  `nvim.bak<unique-id>`

## Usage (for those who want to know what is happening)

### First time
From your home directory (or wherever you want), clone the repository, change
into it, run `./install`, and source `~/.bash_profile`:

```
git clone https://github.com/michael-lehn/hpc0-ubuntu-software.git
cd hpc0-ubuntu-software
./install
source ~/.bash_profile
```

### If you have already cloned the repository before
Change into the repository, pull the latest changes, run `./install` again,
and source `~/.bash_profile`:

```
cd hpc0-ubuntu-software
git pull
./install
source ~/.bash_profile
```
