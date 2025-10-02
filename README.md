# NeoVim Config

This is just my nvim configuration.

## Initial Setup

I use [iTerm2](https://iterm2.com/downloads.html), because `Terminal.app` doesn't can't even render figlet banners right.

Just install all nerd fonts `brew search '/font-.*-nerd-font/' | awk '{ print $1 }' | xargs -I{} brew install --cask {} || true`

Install NeoVim `brew install neovim`

Clone the config.

```
mkdir -p ~/.config && cd $_
git clone git@github.com:samintheshell/nvim.git
```

Open `iTerm2`

Go to `iTerm2 > Settings... > Profiles > Other Actions... > Import JSON Profiles...` and import `iterm2.profile.json`.

Set the new profile as the default.

Go to `iTerm2 > Settings... > Appearance > Theme` select `Minimal`.

Open `nvim` in the terminal.

Some manual Mason installation is necessary.

```
:MasonInstall stylua
:MasonInstall prettier
:MasonInstall black
:MasonInstall isort
:MasonInstall goimports
```

Done.
