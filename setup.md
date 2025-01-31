# Steps to setup

### git clone this repo into home directory

### Change these default Mac settings

- change wallpaper, and also screen saver
- set up messages sync
- set up icloud
- set up internet accounts
- set up keyboard
- orange accent color with dark mode
- setup dock
- set up control center
- more space display
- filter spotlight
- set up track pad
- privacy and security settings, give disk access
- set up folders in finder and finder settings
- set up safari settings

### Install these first manually from the source

- Homebrew
  > Now install dependencies using brew file before installing rest of the packages, might need to set up fonts
- oh my zsh (put this in robbyrussell theme)

```zsh
PROMPT="%n@%m %(?:%{$fg_bold[green]%}%1{➜%} :%{$fg_bold[red]%}%1{➜%} )%{$fg[cyan]%}%c%{$reset_color%}"
```

- Neovim (already in external ssd)
- vscode
- kitty
- app cleaner
- firefox, arc
- bruno
- vpn
- skim (set up sync and command: nvim, arguments: --headless -c "VimtexInverseSearch %line '%file'")
- wblock
- imageoptim
- docker
- xcode and developer tools
- karabiner element
- ollama (already in external ssd)
- vmware (already in external ssd)

Then run the chmod the link.sh file and run it, also symlink stdc++, ollama, neovim manually

<!---
Note that zshrc will probably be broken since some of the packages are installed now using brew instead of from source like before which affects the path. Also copilot will prob break in neovim due to the node path being different since node is being installed by homebrew too so manyally change the node directory in copilot as well
-->
