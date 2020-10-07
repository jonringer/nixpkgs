{ stdenv, lib, makeDesktopItem
, unzip, libsecret, libXScrnSaver, wrapGAppsHook
, gtk2, atomEnv, at-spi2-atk, autoPatchelfHook
, systemd, fontconfig, libdbusmenu, buildFHSUserEnvBubblewrap

# Attributes inherit from specific versions
, version, src, meta, sourceRoot
, executableName, longName, shortName, pname
}:

let
  inherit (stdenv.hostPlatform) system;
  unwrapped = stdenv.mkDerivation {

    inherit pname version src sourceRoot;

    passthru = {
      inherit executableName;
    };

    desktopItem = makeDesktopItem {
      name = executableName;
      desktopName = longName;
      comment = "Code Editing. Redefined.";
      genericName = "Text Editor";
      exec = "${executableName} %U";
      icon = "code";
      startupNotify = "true";
      categories = "Utility;TextEditor;Development;IDE;";
      mimeType = "text/plain;inode/directory;";
      extraEntries = ''
        StartupWMClass=${shortName}
        Actions=new-empty-window;
        Keywords=vscode;

        [Desktop Action new-empty-window]
        Name=New Empty Window
        Exec=${executableName} --new-window %F
        Icon=code
      '';
    };

    urlHandlerDesktopItem = makeDesktopItem {
      name = executableName + "-url-handler";
      desktopName = longName + " - URL Handler";
      comment = "Code Editing. Redefined.";
      genericName = "Text Editor";
      exec = executableName + " --open-url %U";
      icon = "code";
      startupNotify = "true";
      categories = "Utility;TextEditor;Development;IDE;";
      mimeType = "x-scheme-handler/vscode;";
      extraEntries = ''
        NoDisplay=true
        Keywords=vscode;
      '';
    };

    buildInputs = (if stdenv.isDarwin
      then [ unzip ]
      else [ gtk2 at-spi2-atk wrapGAppsHook ] ++ atomEnv.packages)
        ++ [ libsecret libXScrnSaver ];

    runtimeDependencies = lib.optional (stdenv.isLinux) [ (lib.getLib systemd) fontconfig.lib libdbusmenu ];

    nativeBuildInputs = lib.optional (!stdenv.isDarwin) autoPatchelfHook;

    dontBuild = true;
    dontConfigure = true;

    installPhase =
      if system == "x86_64-darwin" then ''
        mkdir -p "$out/Applications/${longName}.app" $out/bin
        cp -r ./* "$out/Applications/${longName}.app"
        ln -s "$out/Applications/${longName}.app/Contents/Resources/app/bin/code" $out/bin/${executableName}
      '' else ''
        mkdir -p $out/lib/vscode $out/bin
        cp -r ./* $out/lib/vscode

        ln -s $out/lib/vscode/bin/${executableName} $out/bin

        mkdir -p $out/share/applications
        ln -s $desktopItem/share/applications/${executableName}.desktop $out/share/applications/${executableName}.desktop
        ln -s $urlHandlerDesktopItem/share/applications/${executableName}-url-handler.desktop $out/share/applications/${executableName}-url-handler.desktop

        mkdir -p $out/share/pixmaps
        cp $out/lib/vscode/resources/app/resources/linux/code.png $out/share/pixmaps/code.png

        # Override the previously determined VSCODE_PATH with the one we know to be correct
        sed -i "/ELECTRON=/iVSCODE_PATH='$out/lib/vscode'" $out/bin/${executableName}
        grep -q "VSCODE_PATH='$out/lib/vscode'" $out/bin/${executableName} # check if sed succeeded
      '';

    inherit meta;
  };
in if !stdenv.isLinux
  # for platforms where buildFHSUserEnv isn't needed or supported
  then unwrapped

  # Vscode and variants allow for users to download and use extensions
  # which often include the usage of pre-built binaries.
  # This has been an on-going painpoint for many users, as
  # a full extension update cycle has to be done through nixpkgs
  # in order to create or update extensions.
  # See: #83288 #91179 #73810 #41189
  #
  # buildFHSUserEnv allows for users to use the existing vscode
  # extension tooling without significant pain.
  else buildFHSUserEnvBubblewrap {
    name = executableName;

    # additional libraries which are commonly needed for extensions
    targetPkgs = pkgs: (with pkgs; [
      # dotnet
      curl
      icu
      libunwind
      libuuid
      openssl
      zlib

      # mono
      krb5
    ]);

    # restore desktop item icons
    extraInstallCommands = ''
      mkdir -p $out/share/applications
      for item in ${unwrapped}/share/applications/*.desktop; do
        ln -s $item $out/share/applications/
      done
    '';

    runScript = "${unwrapped}/bin/${executableName}";

    # vscode likes to kill the parent so that the
    # gui application isn't attached to the terminal session
    dieWithParent = false;

    passthru = {
      inherit unwrapped executableName;
      inherit (unwrapped) pname version; # for home-manager module
    };

    inherit meta;
  }

