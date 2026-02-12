# Summary

This is a collection of my dotfiles and configurations. I use [chezmoi](https://www.chezmoi.io/) to manage and deploy my dotfiles across both macOS and Linux. chezmoi is incredibly powerful, and you'll notice that numerous files are templated, encrypted, or prefixed with `executable`. This is to leverage particular behaviors supported by chezmoi. Nevertheless, when referencing files, I will address them as if they were in their final state.

## Setup

I utilize [starship](https://starship.rs/) for customizing my prompt. My configuration is stored in `starship.toml`. I have separate files for my aliases, exports, completions, and functions. To manage and install plugins, I employ simple zsh functions inspired by [zsh-unplugged](https://github.com/mattmc3/zsh_unplugged), which can be found in the `plugin_manager.zsh` file. All other settings are mainly located in the `.config/` directory.

Regarding terminals, I've tried so many and will likely try more. I've been using [rio](https://rioterm.com) lately and I'm happy with it.But ask me again in a year or so and I'll probably be using something else.

## Installation

To set up my dotfiles, I created a script called `setup.sh`, which will install chezmoi and my dependencies (1password for secrets management and sops/age for encryption) before installing the dotfiles with chezmoi. I then use [Ansible](https://github.com/timmyb824/automation_ansible) to install packages and tooling.

## Thoughts

I use to use [oh-my-zsh](https://ohmyz.sh/), but I found that it was too bloated and slow. It would often take me several seconds to load a new terminal. I decided to switch to a more minimal setup, which has been working well for me. I have been using this setup for many years now, and I have been happy with it.
