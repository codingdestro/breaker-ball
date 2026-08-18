# Breaker

Neon synthwave breakout campaign built with [LÖVE](https://love2d.org/).

## Play from source

```bash
love .
```

## Controls

- `A` / `D` or `Left` / `Right`: move paddle
- `Space`: launch ball / confirm menu
- `P` or `Esc`: pause
- `R`: restart current level

## Build a single Linux binary

This repo includes a build script that fuses the game archive into the LÖVE executable.

```bash
chmod +x scripts/build-linux.sh
./scripts/build-linux.sh
```

Output:

- `dist/breaker-linux-x86_64` (single executable file)

Run it with:

```bash
./dist/breaker-linux-x86_64
```

> Note: the fused binary is a single file, but it still depends on the same shared runtime libraries as LÖVE on Linux.
