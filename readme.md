# Statically compiled tmux with musl libc

Because there are times I have to endure systems I can't update, and
still want tmux to be available.

## Requirements

- docker
- gnu tar

## To build

```
make
```

Or if your tar is named oddly, say gtar:
```
make TAR=gtar
```

And you'll end up with an unstripped tmux binary for x86_64 linux in this
directory.

