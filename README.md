# NeoVim Config

This is just my nvim configuration.

## Installing Nerd Fonts and NeoVim

Nerd fonts are necessary for some of the plugins installed.

This is a very quick and lazy way to install them all.

```
brew install neovim
brew search '/font-.*-nerd-font/' | awk '{ print $1 }' | xargs -I{} brew install --cask {} || true
```

## Terminal Setup

On MacOS, use [iTerm2](https://iterm2.com/downloads.html).

A default profile has been provided [here](https://raw.githubusercontent.com/samintheshell/nvim/refs/heads/main/iterm2.profile.json).

Open `iTerm2`

Go to `iTerm2 > Settings... > Profiles > Other Actions... > Import JSON Profiles...` and import `iterm2.profile.json`.

Set the new profile as the default.

Go to `iTerm2 > Settings... > Appearance > Theme` select `Minimal`.

## Using this Config

Clone the config.

```
mkdir -p ~/.config && cd $_
git clone git@github.com:samintheshell/nvim.git
```

Setup `:Mason` packages for the LSP configuration.

```
nvim --headless \
    -c 'MasonInstall stylua' \
    -c 'MasonInstall prettier' \
    -c 'MasonInstall black' \
    -c 'MasonInstall isort' \
    -c 'MasonInstall goimports' \
    -c 'qa'
```

Open `nvim` in the terminal.

Profit.
