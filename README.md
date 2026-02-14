# Nix Flake for Handy

A Nix flake for [Handy](https://github.com/cjpais/Handy) - a free, open source, offline speech-to-text application.

This flake wraps the upstream Handy package with a configurable text input tool (e.g., `wtype` for Wayland, `xdotool` for X11) so that Handy can type transcribed text into the focused window.

## Installation

### With Home Manager (recommended)

Add the flake to your inputs:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    handy = {
      url = "github:YOUR_USERNAME/nix-handy-stt";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
```

> **Note:** This flake is built against `nixpkgs-unstable`. If you use
> `inputs.nixpkgs.follows` to point to a different nixpkgs channel (e.g., a
> stable release), you may encounter library compatibility issues. For best
> results, ensure your nixpkgs also follows `nixpkgs-unstable`.

Import the module, apply the overlay, and enable it:

```nix
{ inputs, pkgs, ... }:

{
  imports = [ inputs.handy.homeManagerModules.default ];

  nixpkgs.overlays = [ inputs.handy.overlays.default ];

  services.handy.enable = true;
}
```

#### Configuration

The Home Manager module accepts the following options:

| Option | Type | Default | Description |
|---|---|---|---|
| `enable` | `bool` | `false` | Whether to enable Handy |
| `package` | `package` | `pkgs.handy-unwrapped` | The (unwrapped) Handy package to use |
| `textInputTool` | `package` | `pkgs.wtype` | The text input tool to add to PATH |

By default, `wtype` (for Wayland) is added to Handy's PATH. To use a different tool, e.g. `xdotool` for X11:

```nix
services.handy = {
  enable = true;
  textInputTool = pkgs.xdotool;
};
```

### Direct installation

Run directly:

```bash
nix run github:YOUR_USERNAME/nix-handy-stt
```

Or build and run:

```bash
nix build github:YOUR_USERNAME/nix-handy-stt
./result/bin/handy &
```

When using direct installation, the default text input tool is `wtype`.

## Usage Notes

### First Run

On first launch, Handy will prompt you to select a speech-to-text model. Models are downloaded to `~/.local/share/com.pais.handy/`.

## Outputs

### Packages

- `default` / `handy` - Handy wrapped with `wtype` on PATH

### Overlay

`overlays.default` adds the following to `pkgs`:

- `handy` - Wrapped Handy (with `wtype`)
- `handy-unwrapped` - The upstream Handy package without wrapping
- `wrapHandy` - Helper function `handy-pkg: textInputTool: <wrapped derivation>` for custom wrapping

### Home Manager Module

- `homeManagerModules.default` / `homeManagerModules.handy`

## Known Issues

- Bluetooth audio devices may not appear in device selection
- Some ALSA warnings about pulse/jack/oss may appear in logs (harmless)

## License

This flake is provided as-is. Handy itself is MIT licensed.
