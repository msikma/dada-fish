# Dada Fish

My personal [Fish](https://fishshell.com/) setup.

## Installation

Clone this repository to `~/.config/dada-fish` or symlink it there.

Append this command to `~/.config/fish/config.fish` to run it on startup:

```fish
echo "if status is-interactive; source ~/.config/dada-fish/src/main.fish; end" >> ~/.config/fish/config.fish
```

## Configuration

If running on a server, set the following environment variable before loading:

```fish
set -gx DADA_FISH_ENV "server"
```

To use the backup commands, set a backup base directory. Backups are created in a directory named after your machine's hostname.

```fish
set -gx DADA_BACKUP_MACHINE_BASE "/path/to/backups"
```

## External links

* [Fish Shell](https://fishshell.com/)
* [Setting Fish as the default shell on macOS](https://stackoverflow.com/a/26321141) (stackoverflow.com)

## Copyright

MIT license
