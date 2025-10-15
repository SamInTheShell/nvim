## Dependencies

```shell
apt update && apt install -y build-essential nodejs npm golang unzip python3-venv
```

## Neovim Install

Source: https://github.com/neovim/neovim/blob/master/INSTALL.md

```
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
rm -rf /opt/nvim-linux-x86_64 && tar -C /opt -xzf nvim-linux-x86_64.tar.gz
echo 'export PATH="$PATH:/opt/nvim-linux-x86_64/bin"' >> ~/.bashrc
source ~/.bashrc
```
