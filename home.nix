{ lib, config, pkgs, ... }:
let
  inherit (pkgs) stdenv;
  doom-emacs = pkgs.callPackage (builtins.fetchTarball {
    url =
      "https://github.com/nix-community/nix-doom-emacs/archive/master.tar.gz";
  }) {
    doomPrivateDir = ./doom.d; # Directory containing your config.el init.el
    # and packages.el files
  };

in rec {
  imports =
    [ ./programs/config.nix ./services/config.nix ./xsession/config.nix ];
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "aizuzu";
  home.homeDirectory = "/home/aizuzu";
  # Unfree packages wanted
  #nixpkgs.config.allowUnfree = true;

  home.file = {
    # Set unfree here too
    ".config/nixpkgs/config.nix" = {
      text = ''
        {allowUnfree = true; }
      '';
    };
    ".config/nvim/coc-settings.json" = {
      text = ''
        {
          "rust-analyzer": {
            "enable": true,
            "server": {
              "path": "${pkgs.rust-analyzer}/bin/rust-analyzer",
            },
            "procMacro": {
              "enable": true,
            },
            "lens": {
              "run": true,
              "implementations": true,
              "methodReferences": true,
            },
          }
        }
      '';
    };
    ".profile" = {
      text = ''
        . "$HOME/.nix-profile/etc/profile.d/nix.sh"
      '';
    };

    ".config/nvim/autoload/.keep".text = "";
    ".config/nvim/swapfiles/.keep".text = "";
    ".config/nvim/undofiles/.keep".text = "";
    ".config/nvim/Ultisnips/.keep".text = "";

    ".cargo/config".text = ''
      [alias]
      gen = "generate"

      [cargo-new]
      name = "${config.programs.git.userName}"
      email = "${config.programs.git.userEmail}"
      vcs = "git"
    '';

    ".local/bin/set-title" = {
      text = ''
        #!${pkgs.bash}/bin/bash
        set-title() {
          echo -ne "\033]0;$@\007"
        }

        set-title $@
      '';
      executable = true;
    };
    ".emacs.d/init.el".text = ''
      (load "default.el")
    '';
  };

  manual = {
    html.enable = true;
    json.enable = true;
    manpages.enable = true;
  };

  home.packages = with pkgs; [
    (import ./rename-padded-numbers.nix { inherit pkgs; })
    tokei
    nixfmt
    niv
    tig
    restic
    zstd
    mosh
    rclone
    carnix
    man-pages
    less
    ffmpeg
    youtube-dl
    tealdeer
    procs
    # rustup
    rustc
    rust-analyzer
    cargo
    rustfmt
    # rust
    llvmPackages.bintools-unwrapped
    openssl
    openssl.dev
    fontconfig
    peco
    kopia
    clang
    (import ./slower.nix {
      inherit pkgs;
      inherit lib;
    })
    openssh
    nodejs
    lynx
    wrangler
    wasm-pack
    cargo-generate
    coreutils-full
    ncurses6
    doom-emacs
    age
    cascadia-code
    (nerdfonts.override {
      fonts = [
        "OpenDyslexic"
        "Hack"
        "FiraCode"
        "FiraMono"
        "CascadiaCode"
        "Iosevka"
        "Meslo"
        "MPlus"
        "SourceCodePro"
      ];
    })
  ];
  home.sessionVariables = {
    EDITOR = "${pkgs.neovim}/bin/nvim";
    BROWSER = "${pkgs.lynx}/bin/lynx";
    DOTNET_ROOT = "${pkgs.dotnet-sdk}";
    DOTNET_CLI_TELEMETRY_OPTOUT = 1;
    DOTNET_SKIP_FIRST_TIME_EXPERIENCE = 1;
    RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
    PATH = "$HOME/.cargo/bin:$PATH";
  };

  home.sessionVariablesExtra = ''
    . "$HOME/.nix-profile/etc/profile.d/nix.sh"
  '';

  home.sessionPath = [ "~/.local/bin" "${pkgs.dotnet-sdk}/bin" ];

  home.keyboard = { layout = true; };

  fonts.fontconfig.enable = lib.mkDefault true;

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.05";
}
