# Summary

This is a collection of my dotfiles and configurations. I use [chezmoi](https://www.chezmoi.io/) to manage and deploy my dotfiles across both macOS and Linux. chezmoi is incredibly powerful, and you'll notice that numerous files are templated, encrypted, or prefixed with `executable`. This is to leverage particular behaviors supported by chezmoi. Nevertheless, when referencing files, I will address them as if they were in their final state.

## Setup

I utilize [starship](https://starship.rs/) for customizing my prompt. My configuration is stored in `starship.toml`. I have separate files for my aliases, exports, completions, and functions. To manage and install plugins, I employ simple zsh functions inspired by [zsh-unplugged](https://github.com/mattmc3/zsh_unplugged), which can be found in the `plugin_manager.zsh` file. All other settings are mainly located in the `.config/` directory.

Regarding terminals, I prefer using [iterm2](https://iterm2.com/). Any custom settings can be found in the `iterm2_configs` directory. I've tried many different terminal emulators, including hyper.js, warp, alacritty, kitty, and tabby but I find that I keep coming back to iterm2 for one reason or another.

## Installation

To set up my dotfiles, I've created various custom bash scripts. The primary script is `setup.sh`, which will set up chezmoi and my dependencies (1password for secrets management and sops/age for encryption) before installing the dotfiles with chezmoi. It will then call the `.config/bin/install.sh` script, to handle the installation of packages and tooling.

## Thoughts

I use to use [oh-my-zsh](https://ohmyz.sh/), but I found that it was too bloated and slow. It would often take me several seconds to load a new terminal. I decided to switch to a more minimal setup, which has been working well for me. I have been using this setup for many months now, and I have been happy with it.

