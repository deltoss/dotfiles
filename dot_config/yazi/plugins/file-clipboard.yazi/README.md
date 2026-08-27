# Local installation note

This [plugin](https://github.com/XYenon/clipboard.yazi) is installed locally as `file-clipboard.yazi` because Yazi reserves `clipboard` for a built-in module. Keep its keymap commands in this form:

```toml
run = 'plugin file-clipboard -- --action=copy'
run = 'plugin file-clipboard -- --action=paste'
```

The built-in module is not a replacement for this plugin. Yazi's `copy path` command copies path text, while this plugin puts file references on the system clipboard so files can be pasted to and from graphical file managers.

This copy is intentionally absent from `package.toml`. Yazi's package manager derives the install directory from `XYenon/clipboard`, so tracking it there would recreate the conflicting `plugins/clipboard.yazi` directory.

## Updating this local copy

Install the latest upstream package temporarily, copy its runtime file over this renamed copy, then remove the temporary package:

```nu
ya pkg add XYenon/clipboard
open --raw ~/.config/yazi/plugins/clipboard.yazi/main.lua
| save --force ~/.config/yazi/plugins/file-clipboard.yazi/main.lua
ya pkg delete XYenon/clipboard
```

Check the [upstream repository](https://github.com/XYenon/clipboard.yazi) for new runtime files or assets before updating. If any were added, copy those too while preserving this local note. If package deletion leaves an empty `plugins/clipboard.yazi` directory, close running Yazi instances and remove it.
