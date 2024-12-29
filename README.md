> [!NOTE]
>
> This repo is now deprecated because of https://github.com/NixOS/nixpkgs/pull/358586

# Patched Caddy NixOS flake

Caddy's third-party plugins are installed by adding them as import in
`cmd/caddy/main.go` and compiling caddy. This can be done either using
the `xcaddy` utility as described [here](https://caddyserver.com/docs/build)
in the official docs or by creating a `main.go` file with the import and
compiling with `go build` manually. This process is outlined in the upstream
[here](https://github.com/caddyserver/caddy/blob/82c356f2548ca62b75f76104bef44915482e8fd9/cmd/caddy/main.go#L21-L25).
The `xcaddy` utility is not suited for deployment on NixOS where a sandboxed,
reproducible build is required.

This flake compiles caddy from a custom `main.go` file as outlined above,
currently only adding the cloudflare dns plugin. The `caddy` package of
this flake's output will be caddy with that plugin baked in.

To modify/add plugins:

1. Edit `src/main.go` as per the upstream docs
2. Run `go mod tidy`
3. If necessary, update the hash in `flake.nix`
4. Run `nix build`

You should get a result with the compiled caddy. To verify that the plugins
were correctly added use:

```sh
./result/bin/caddy list-modules
```

You should see the non-standard modules you added above this line at the end:

```sh
  Non-standard modules: n
```


## Cachix
To make use of this repository's cachix binary cache, you can follow the
instructions at this [link](https://app.cachix.org/cache/caddycf#pull),
or add these to your nix configuration:

```nix
{
  nix.settings = {
    substituters = [
      "https://caddycf.cachix.org"
    ];

    trusted-public-keys = [
      "caddycf.cachix.org-1:6vbQaeiec/zKv9XfEwi9yWVCe7opbeJMu6w81UEXugY="
    ];
  };
}
```
