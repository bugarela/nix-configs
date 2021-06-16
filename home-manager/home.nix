{ config, pkgs, lib, ... }:

let
  unstable = import <nixpkgs-unstable> { config.allowUnfree = true; overlays = [(self: super: { discord = super.discord.overrideAttrs (_: { src = builtins.fetchTarball "https://discord.com/api/download?platform=linux&format=tar.gz"; });})];};
  emacs-overlay = builtins.fetchTarball "https://github.com/nix-community/emacs-overlay/archive/15ed1f372a83ec748ac824bdc5b573039c18b82f.tar.gz";
  emacsPkgs = import <nixpkgs> { overlays = [ (import emacs-overlay) ]; };
  mypolybar = (pkgs.polybar.overrideAttrs (old: {
    nativeBuildInputs = old.nativeBuildInputs ++ [
      pkgs.python38Packages.sphinx
    ];
    src = pkgs.fetchFromGitHub {
      owner = old.pname;
      repo = old.pname;
      rev    = "10bbec44515d2479c0dd606ae48a2e0721ad94c0";
      sha256 = "0kzv6crszs0yx70v0n89jvv40155chraw3scqdybibk4n1pmbkzn";
      fetchSubmodules = true;
    };
  })).override {
    i3Support = false;
    i3GapsSupport = false;
    alsaSupport = true;
    iwSupport = false;
    githubSupport = true;
    mpdSupport = true;
    nlSupport = true;
    pulseSupport = false;
  };
in {
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
  home.stateVersion = "21.03";

  imports = [
    ./programs/xmonad/default.nix
  ];

  home.username = "gabriela";
  home.homeDirectory = "/home/gabriela";

  home.sessionVariables = {
    PAGER = "less";
    EDITOR = "vim";
    DOOMDIR = "$HOME/nix-configs/doom.d";
    EMACSDIR = "$HOME/.emacs.d";
    DOOMLOCALDIR = "$HOME/.doom_local";
    DIRENV_ALLOW_NIX = 1;
  };

  home.file.".rd-docker-installer" = {
    source =  builtins.fetchGit {
      url = "ssh://git@github.com/ResultadosDigitais/rd-docker.git";
      rev = "cf1aeca3e9a5588d26360f3bb2618977cdceb247";
    };
    onChange =  "${pkgs.writeShellScript "rd-docker-change" ''
      cd ~/.rd-docker-installer
      cp rd-docker-install /tmp/rd-docker-install
      sed 's/sudo ln/# sudo ln/' -i /tmp/rd-docker-install
      cat /tmp/rd-docker-install | bash
    ''}";
  };

  home.file.".doom.d" = {
    source = builtins.toPath "/home/gabriela/nix-configs/doom.d";
    onChange = "${pkgs.writeShellScript "doom-change" ''
      EMACSDIR=/home/gabriela/.emacs.d
      DOOMBIN="$EMACSDIR"/bin/doom
      DOOMLOCALDIR=/home/gabriela/.doom_local
      mkdir -p "$DOOMLOCALDIR"
      mkdir -p /home/gabriela/org/roam
      if [ ! -f "$DOOMBIN" ]; then
        echo "-------------> Installing DOOM EMACS"
        mv "$EMACSDIR" "$EMACSDIR".bk
        git clone --depth 1 https://github.com/hlissner/doom-emacs.git "$EMACSDIR"
        "$DOOMBIN" -y install
      else
        echo "-------------> Syncing DOOM EMACS"
        "$DOOMBIN" -y sync
      fi
    ''}";
  };

  nixpkgs.config.allowUnfree = true;

  home.packages = [
    pkgs.ripgrep
    pkgs.jq
    pkgs.autorandr
    pkgs.tree
    pkgs.rnix-lsp
    pkgs.lazydocker
    pkgs.libgccjit
    pkgs.xorg.xwininfo
    pkgs.xmobar
    pkgs.xdotool
    pkgs.lxrandr
    pkgs.pscircle
    pkgs.gpicview
    pkgs.feh
    pkgs.neofetch
    pkgs.lxappearance
    pkgs.evince
    pkgs.gimp
    pkgs.inxi
    pkgs.pciutils
    pkgs.glxinfo
    pkgs.lm_sensors
    (pkgs.aspellWithDicts (d: [d.en]))

    pkgs.networkmanagerapplet

    pkgs.qbittorrent
    pkgs.spotify
    pkgs.pcmanfm
    unstable.vivaldi
    pkgs.synergy
    pkgs.tdesktop
    unstable.discord
    pkgs.slack
    pkgs.flameshot
    pkgs.copyq

    # emacsPkgs.emacsGcc
    pkgs.emacs

    pkgs.megasync
    pkgs.tlaplus
    pkgs.sqlite
    pkgs.texlive.combined.scheme-full
    pkgs.nitrogen
    pkgs.killall
  ];

  programs.git = {
    enable = true;
    userName = "gabrielamafra";
    userEmail = "gabrielamoreiramafra@gmail.com";
  };

  programs.fish = {
    enable = true;
    shellInit = builtins.readFile ./programs/fish/config.fish;

    # sessionVariables = rec {
    #   EDITOR = "vim";
    #   VISUAL = EDITOR;
    #   GIT_EDITOR = EDITOR;
    #   DOOMLOCALDIR = "$HOME/.doom_local";
    #   DOOMDIR = "$HOME/nix-configs/doom.d";
    #   DIRENV_ALLOW_NIX = 1;
    # };
  };

  programs.bash = {
    enable = true;
    shellAliases = {
      ls = "ls --color=auto";
    };
  };

  programs.neovim = {
    enable = true;
    vimAlias = true;
    extraConfig = builtins.readFile ./programs/vim/extraConfig.vim;

    plugins = with pkgs.vimPlugins; [
      # Syntax / Language Support ##########################
      vim-nix
      vim-ruby # ruby
      vim-go # go
      # vim-fish # fish
      # vim-toml           # toml
      # vim-gvpr           # gvpr
      # rust-vim # rust
      zig-vim
      vim-pandoc # pandoc (1/2)
      vim-pandoc-syntax # pandoc (2/2)
      # yajs.vim           # JS syntax
      # es.next.syntax.vim # ES7 syntax

      # UI #################################################
      nord-vim # colorscheme
      vim-gitgutter # status in gutter
      # vim-devicons
      vim-airline

      # Editor Features ####################################
      vim-surround # cs"'
      vim-repeat # cs"'...
      vim-commentary # gcap
      # vim-ripgrep
      vim-indent-object # >aI
      vim-easy-align # vipga
      vim-eunuch # :Rename foo.rb
      vim-sneak
      supertab
      # vim-endwise        # add end, } after opening block
      # gitv
      # tabnine-vim
      ale # linting
      nerdtree
      # vim-toggle-quickfix
      # neosnippet.vim
      neosnippet-snippets
      # splitjoin.vim
      nerdtree

      # Buffer / Pane / File Management ####################
      fzf-vim # all the things

      # Panes / Larger features ############################
      tagbar # <leader>5
      vim-fugitive # Gblame
    ];
  };

  programs.alacritty = {
    enable = true;

    settings = {
      scrolling.history = 10000;
      TERM = "xterm-256color";

      window = {
        padding = {
          x = 5;
          y = 5;
        };
      };

      draw_bold_text_with_bright_colors = true;
      font = {
        normal.family = "Iosevka";
        normal.style = "Regular";
        bold.family = "Iosevka";
        bold.style = "Regular";
        italic.family = "Iosevka";
        italic.style = "Regular";
        blod_italic.family = "Iosevka";
        blod_italic.style = "Regular";
        size = 10.0;
      };

      colors = {
        primary = {
          background = "0x282c34";
          foreground = "0xbbc2cf";
        };

        cursor = {
          background = "0xFFFFFF";
          foreground = "0x222222";
        };

        vi_mode_cursor = {
          background = "0xFFFFFF";
          foreground = "0xbbc2cf";
        };

        selection= {
          text = "0x000000";
          background = "0x44475a";
        };

        normal = {
          black   = "0x000000";
          red     = "0xff6c6b";
          green   = "0x98be65";
          yellow  = "0xecbe7b";
          blue    = "0x596889";
          magenta = "0xc678dd";
          cyan    = "0x46d9ff";
          white   = "0xdfdfdf";
        };

        bright = {
          black   = "0x3f444a";
          red     = "0xff6c6b";
          green   = "0x98be65";
          yellow  = "0xecbe7b";
          blue    = "0x51afef";
          magenta = "0xc678dd";
          cyan    = "0x46d9ff";
          white   = "0x9ca0a4";
        };
      };
    };
  };

  programs.autorandr.enable = true;

  # Interface stuff
  programs.rofi = {
    enable = true;
    terminal = "${pkgs.alacritty}/bin/alacritty";
    theme = ./programs/rofi/theme.slate;
    cycle = true;
  };

  gtk = {
    enable = true;
    theme.package = pkgs.qogir-theme;
    # theme.name = "Adwaita-dark";
    theme.name = "Qogir-dark";
    iconTheme = {
      name = "Zafiro-icons";
      package = pkgs.zafiro-icons;
    };
  };

  xsession.pointerCursor = {
    package = pkgs.qogir-icon-theme;
    name = "Qogir-dark";
    size = 28;
  };

  # Autoload nix shells
  # services.lorri.enable = true;

  services.polybar = {
    enable = true;
    package = mypolybar;
    config = ./programs/polybar/config.ini;
    script = ''
    '';
  };

  services.udiskie = {
    enable = true;
    tray = "always";
  };

  programs.direnv.enable = true;
  programs.direnv.enableNixDirenvIntegration = true;
}
