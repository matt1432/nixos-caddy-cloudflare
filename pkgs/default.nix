{
  lib,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  stdenv,
  ...
}: let
  info = import ./info.nix;
  dist = fetchFromGitHub info.dist;

  caddy-version = info.version;
  cloudflare-version = info.cfVersion;
in
  buildGoModule {
    pname = "caddy-with-plugins";
    version = caddy-version + "-" + cloudflare-version;

    src = ../src;

    runVend = true;
    inherit (info) vendorHash;

    # Everything past this point is from Nixpkgs
    ldflags = [
      "-s"
      "-w"
      "-X github.com/caddyserver/caddy/v2.CustomVersion=${caddy-version}"
    ];

    # matches upstream since v2.8.0
    tags = ["nobadger"];

    nativeBuildInputs = [installShellFiles];

    postInstall =
      ''
        install -Dm644 ${dist}/init/caddy.service ${dist}/init/caddy-api.service -t $out/lib/systemd/system

        substituteInPlace $out/lib/systemd/system/caddy.service \
          --replace-fail "/usr/bin/caddy" "$out/bin/caddy"
        substituteInPlace $out/lib/systemd/system/caddy-api.service \
          --replace-fail "/usr/bin/caddy" "$out/bin/caddy"
      ''
      + lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
        # Generating man pages and completions fail on cross-compilation
        # https://github.com/NixOS/nixpkgs/issues/308283

        $out/bin/caddy manpage --directory manpages
        installManPage manpages/*

        installShellCompletion --cmd caddy \
          --bash <($out/bin/caddy completion bash) \
          --fish <($out/bin/caddy completion fish) \
          --zsh <($out/bin/caddy completion zsh)
      '';

    meta = {
      homepage = "https://caddyserver.com";
      description = "Fast and extensible multi-platform HTTP/1-2-3 web server with automatic HTTPS";
      license = lib.licenses.asl20;
      mainProgram = "caddy";
    };
  }
