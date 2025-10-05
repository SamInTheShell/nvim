Installing OMP.

```
brew install jandedobbeleer/oh-my-posh/oh-my-posh
```

Initial setup.

```
eval "$(oh-my-posh init zsh --config ~/.config/nvim/omp.yaml)"
```

Debugging.

```
oh-my-posh config export --format yaml
oh-my-posh print primary --config ~/.config/nvim/omp.yaml
oh-my-posh print primary --config ~/.config/nvim/omp.yaml --status 1
```
