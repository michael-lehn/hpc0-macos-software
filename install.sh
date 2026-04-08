#!/usr/bin/env bash
install_if_missing() {
    if ! brew list "$1" >/dev/null 2>&1; then
        echo "📦 Installing $1..."
        brew install "$1"
    else
        echo "✔️  $1 already installed"
    fi
}

add_to_file() {
    local line="$1"
    local file="$2"

    # Create file if it does not exist
    touch "$file"

    # Check if line (without comment) already exists
    if ! grep -Fq "$line" "$file"; then
        echo "$line  # HPC0" >> "$file"
        echo "✅ Added to $file: $line"
    else
        echo "✔️ Already present in $file: $line"
    fi
}

clone_or_pull() {
    local repo_url="$1"
    local target_dir="$2"

    # If no target dir given → derive from repo name
    if [ -z "$target_dir" ]; then
        target_dir="$(basename "$repo_url" .git)"
    fi

    if [ -d "$target_dir/.git" ]; then
        echo "🔄 Updating $target_dir..." >&2
        git -C "$target_dir" pull
    else
        echo "📥 Cloning $repo_url into $target_dir..." >&2
        git clone "$repo_url" "$target_dir"
    fi
}

clone_or_pull_target_dir() {
    local repo_url="$1"
    local target_dir="$2"

    # If no target dir given → derive from repo name
    if [ -z "$target_dir" ]; then
        target_dir="$(basename "$repo_url" .git)"
    fi

    # Return the directory (absolute path is safer)
    (cd "$target_dir" && pwd)
}


safe_symlink() {
    local source="$1"
    local target="$2"

    # If target is already the correct symlink → nothing to do
    if [ -L "$target" ] && [ "$(readlink "$target")" = "$source" ]; then
        echo "✔️ Symlink already correct: $target -> $source"
        return
    fi

    # If target exists → create numbered backup
    if [ -e "$target" ] || [ -L "$target" ]; then
        local i=0
        while [ -e "${target}.bak$i" ] || [ -L "${target}.bak$i" ]; do
            i=$((i+1))
        done
        local backup="${target}.bak$i"

        echo "📦 Backing up $target to $backup"
        mv "$target" "$backup"
    fi

    # Ensure parent directory exists
    mkdir -p "$(dirname "$target")"

    echo "🔗 Creating symlink: $target -> $source"
    ln -s "$source" "$target"
}

#-------------------------------------------------------------------------------
# Update profile
#-------------------------------------------------------------------------------

# Detect shell profile
if [ -n "$ZSH_VERSION" ]; then
    PROFILE="$HOME/.zprofile"
else
    PROFILE="$HOME/.bash_profile"
    add_to_file 'export BASH_SILENCE_DEPRECATION_WARNING=1' "$PROFILE"
fi

# patch profile if needed
add_to_file 'eval "$($(command -v brew) shellenv)"' "$PROFILE"

# just in case activate brew
eval "$(/usr/local/bin/brew shellenv)"


#-------------------------------------------------------------------------------
# Install packages
#-------------------------------------------------------------------------------
export HOMEBREW_NO_ENV_HINTS=1

echo "🔧 Updating package list..."
brew update

echo "🔧 Upgrading packages..."
brew upgrade

install_if_missing eza
install_if_missing gcc
install_if_missing make
install_if_missing nano
install_if_missing wget
install_if_missing neovim
install_if_missing python
install_if_missing npm
install_if_missing python-tk
install_if_missing tree-sitter-cli
install_if_missing llvm
install_if_missing autoconf
install_if_missing automake
install_if_missing autoconf-archive
install_if_missing pkg-config
install_if_missing libtool
install_if_missing dockutil
install_if_missing ripgrep
install_if_missing texlive
install_if_missing nvr

# Update profile to find make
MAKE_PREFIX="$(brew --prefix make 2>/dev/null)"

if [ -n "$MAKE_PREFIX" ]; then
    add_to_file "PATH=\"$MAKE_PREFIX/libexec/gnubin:\$PATH\"" "$PROFILE"
    export PATH="$MAKE_PREFIX/libexec/gnubin:$PATH"
else
    echo "⚠️ make not found via brew, skipping PATH update"
fi

# Update profile to find python3
PYTHON_PREFIX="$(brew --prefix python 2>/dev/null)"

if [ -n "$PYTHON_PREFIX" ]; then
    add_to_file "PATH=\"$PYTHON_PREFIX/bin:\$PATH\"" "$PROFILE"
    export PATH="$PYTHON_PREFIX/bin:$PATH"
else
    echo "⚠️ python not found via brew, skipping PATH update"
fi

# Update profile to find llvm
LLVM_PREFIX="$(brew --prefix llvm 2>/dev/null)"

if [ -n "$LLVM_PREFIX" ]; then
    add_to_file "PATH=\"$LLVM_PREFIX/bin:\$PATH\"" "$PROFILE"
    export PATH="$LLVM_PREFIX/bin:$PATH"
else
    echo "⚠️ llvm not found via brew, skipping PATH update"
fi

#-------------------------------------------------------------------------------
# Configure Neovim
#-------------------------------------------------------------------------------

echo "📦 Configure neovim"
git_repos=https://github.com/michael-lehn/neovim-config-lsp
clone_or_pull $git_repos
NVIM_DIR="$(clone_or_pull_target_dir $git_repos)"
safe_symlink "$NVIM_DIR" "$HOME/.config/nvim"
add_to_file "alias vim=nvim" "$PROFILE"
add_to_file "alias vim=nvim" "$PROFILE"
add_to_file "alias ls=eza" "$PROFILE"
add_to_file "alias texvim='SOCKET=/tmp/nvim; rm -f $SOCKET; nvim --listen \$SOCKET'" "$PROFILE"

#-------------------------------------------------------------------------------
# Configure nano
#-------------------------------------------------------------------------------

echo "📦 Configure nano"
git_repos=https://github.com/michael-lehn/nano-config.git
clone_or_pull $git_repos
NANO_DIR="$(clone_or_pull_target_dir $git_repos)"
safe_symlink "$NANO_DIR"/nanorc "$HOME/.nanorc"
safe_symlink "$NANO_DIR"/nano "$HOME/.nano"

#-------------------------------------------------------------------------------
# Configure shell
#-------------------------------------------------------------------------------
echo "📦 Configure shell to use vi mode"
add_to_file "set -o vi" "$PROFILE"

#-------------------------------------------------------------------------------
# Configure clang-format
#-------------------------------------------------------------------------------

echo "📦 Configure clang-format"
git_repos=https://github.com/michael-lehn/clang-format.git
clone_or_pull $git_repos
CF_DIR="$(clone_or_pull_target_dir $git_repos)"
safe_symlink "$CF_DIR"/clang-format "$HOME/.clang-format"


#-------------------------------------------------------------------------------
# Build abc
#-------------------------------------------------------------------------------

echo "📦 Building and installing abc compiler"
git_repos=https://github.com/michael-lehn/abc-llvm.git
clone_or_pull $git_repos
ABC_DIR="$(clone_or_pull_target_dir $git_repos)"
(cd "$ABC_DIR" && make && make install)

#-------------------------------------------------------------------------------
# Build finalcut
#-------------------------------------------------------------------------------

echo "📦 Building and installing finalcut library"
git_repos=https://github.com/michael-lehn/finalcut.git
clone_or_pull $git_repos
FC_DIR="$(clone_or_pull_target_dir $git_repos)"
(cd "$FC_DIR" && autoreconf --install --force; \
    autoreconf --install --force \
    && ./configure --prefix=/usr/local && make && make install)


#-------------------------------------------------------------------------------
# Build and test ULM generator
#-------------------------------------------------------------------------------

echo "📦 Building and testing ULM generator"
git_repos=https://github.com/michael-lehn/ulm-generator.git
clone_or_pull $git_repos
UG_DIR="$(clone_or_pull_target_dir $git_repos)"
(cd "$UG_DIR" && make install)

ulm-generator --fetch ulm-ice40.isa
ulm-generator --install ulm-ice40.isa
echo "10100020202100001402000004000004302000001211000105FFFFFB0141000068656C6C6F2C20776F726C64210A00" > hello
ulm hello

#-------------------------------------------------------------------------------
# Install and configure iterm2
#-------------------------------------------------------------------------------

APP="/Applications/iTerm.app"

if [ -d "$APP" ]; then
    echo "iTerm2 already installed. Skipping installation."
else
    echo "Installing iTerm2..."

    curl -L -o iterm2.zip https://iterm2.com/downloads/stable/latest
    unzip -q iterm2.zip

    mv iTerm.app /Applications/
    mkdir -p "$HOME"/"Library/Application Support/iTerm2/DynamicProfiles"
    cp HPC0.json "$HOME"/"Library/Application Support/iTerm2/DynamicProfiles"
    GUID="46D020C0-F234-4847-ACBF-BA562CE44F7A"
    defaults write com.googlecode.iterm2 "Default Bookmark Guid" -string "$GUID"
    dockutil --add /Applications/iTerm.app
    cp nerdfonts/* /Library/Fonts

    echo "iTerm2 installed."
fi

#-------------------------------------------------------------------------------
# Install and configure skim
#-------------------------------------------------------------------------------

APP="/Applications/Skim.app"

if [ -d "$APP" ]; then
    echo "Skim already installed. Skipping installation."
else
    echo "Installing Skim..."
    brew install skim --cask
    defaults write net.sourceforge.skim-app.skim \
        SKTeXEditorCommand -string "nvr"
    defaults write net.sourceforge.skim-app.skim \
        SKTeXEditorArguments -string "--servername /tmp/nvim --remote +\"%line\" \"%file\""
    defaults write net.sourceforge.skim-app.skim \
        SKTeXEditorPreset -int 3
fi
