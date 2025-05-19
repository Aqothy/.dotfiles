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

- xcode and developer tools

- Homebrew

  > Now install dependencies using brew file before installing rest of the packages, might need to set up fonts

- vscode
- kitty
- app cleaner
- firefox, arc
- bruno
- vpn
- skim (set up sync and command: nvim, arguments: --headless --noplugin --server /tmp/nvim --remote-send "<c-\\><c-n><cmd>%line | normal zz<cr>" %file)
- wblock
- docker
- karabiner element
- ollama (already in external ssd)
- vmware (already in external ssd)
- go, lua, nvm, yt-dlp, basictex

Then run the chmod the link.sh file and run it, also symlink stdc++, ollama, neovim manually

<!---
Note that zshrc will probably be broken since some of the packages are installed now using brew instead of from source like before which affects the path. Also copilot will prob break in neovim due to the node path being different since node is being installed by homebrew too so manyally change the node directory in copilot as well
-->
