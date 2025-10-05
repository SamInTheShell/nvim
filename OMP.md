Installing OMP.

```
brew install jandedobbeleer/oh-my-posh/oh-my-posh
```

Initial setup.

Example `~/.zshrc`

```
source ~/.config/nvim/shells/zshrc
```

Example `~/.bashrc`

```
source ~/.config/nvim/shells/bashrc
```

Note that some systems, `~/.bash_profile` may need to source `~/.bash_rc`.

```
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi
```

Debugging.

```
oh-my-posh config export --format yaml
oh-my-posh print primary --config ~/.config/nvim/omp.yaml
oh-my-posh print primary --config ~/.config/nvim/omp.yaml --status 1
```
