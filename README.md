# Summary

This is a collection of my dotfiles and configurations. I use [chezmoi](https://www.chezmoi.io/) to manage and deploy my dotfiles.

## Setup

I utilize [starship](https://starship.rs/) for customizing my prompt. My configuration is stored in `starship.toml`. I have separate files for my aliases and functions. To manage and install plugins, I employ simple zsh functions inspired by [zsh-unplugged](https://github.com/mattmc3/zsh_unplugged), which can be found in the `plugin_manager.zsh` file. All other settings are located in `zshrc`.

Regarding terminals, I prefer using a combination of [hyper.js](https://hyper.is/) and [warp](https://www.warp.dev/). Each terminal offers specific features that I can leverage based on the task or situation at hand. For example, I prefer to use hyper.js when I am working on a remote machine.

Additionally, you may notice comments next to certain lines in my `.zshrc`. These serve as reminders of which package manager I used to install a particular tool. While I rely on homebrew for specific cases where it is necessary or makes sense, I have transitioned to using [pkgx](https://docs.pkgx.sh/) for most other packages. Although it is still relatively new, I have encountered a few minor issues. However, I appreciate its concept and its efforts to minimize system pollution.

## Thoughts

I use to use [oh-my-zsh](https://ohmyz.sh/), but I found that it was too bloated and slow. It would often take me many seconds to load a new terminal. I decided to switch to a more minimal setup, which has been working well for me. I have been using this setup for a month now, and I have been happy with it. I have been able to keep it relatively simple and easy to maintain. I have also been able to keep it consistent across multiple machines and operating systems.
