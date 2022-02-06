{ stdenvNoCC }:

{ name ? "test"
, src
, dontFixup ? true
, dontBuild ? true
, dontConfigure ? true
, doCheck ? true
, dontStrip ? true
, ...
}@args:

stdenvNoCC.mkDerivation ({
  inherit name src dontBuild dontFixup dontConfigure dontStrip;

  # realisation will fail unless something is written to $out
  installPhase = ''
    runHook preInstall

    if [ ! -e $out ]; then
      touch $out
    fi

    runHook postInstall
  '';

} // args)
