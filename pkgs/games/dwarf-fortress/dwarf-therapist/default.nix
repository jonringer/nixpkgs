{ lib, stdenv, fetchFromGitHub, qtbase
, qtdeclarative, cmake, wrapQtAppsHook, texlive, ninja }:

stdenv.mkDerivation rec {
  pname = "dwarf-therapist";
  version = "41.2.1";

  src = fetchFromGitHub {
    owner = "Dwarf-Therapist";
    repo = "Dwarf-Therapist";
    rev = "v${version}";
    sha256 = "sha256-j8AX6B7GV/FRZapDcmhItoULc5xIGsUAKqa5V2v7bHI=";
  };

  nativeBuildInputs = [ texlive cmake ninja wrapQtAppsHook ];
  buildInputs = [ qtbase qtdeclarative ];

  installPhase = lib.optional stdenv.isDarwin ''
    mkdir -p $out/Applications
    cp -r DwarfTherapist.app $out/Applications
  '';

  meta = with lib; {
    description = "Tool to manage dwarves in a running game of Dwarf Fortress";
    maintainers = with maintainers; [ abbradar bendlas numinit jonringer ];
    license = licenses.mit;
    platforms = platforms.unix;
    homepage = "https://github.com/Dwarf-Therapist/Dwarf-Therapist";
  };
}
