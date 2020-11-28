{ stdenv, fetchFromGitHub, cmake, curl, tzdata, fetchpatch, substituteAll }:

stdenv.mkDerivation rec {
  pname = "howard-hinnant-date";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "HowardHinnant";
    repo = "date";
    rev = "v${version}";
    sha256 = "1qvlx6yzjsacj8zwl8k43cm00l1c41xdp1fqm8sq7ilglw06x8jk";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ curl ];

  cmakeFlags = [
    "-DBUILD_TZ_LIB=true"
    "-DBUILD_SHARED_LIBS=true"
    "-DUSE_SYSTEM_TZ_DB=true"
  ];

  outputs = [ "out" "dev" ];

  meta = with stdenv.lib; {
    license = licenses.mit;
    description = "A date and time library based on the C++11/14/17 <chrono> header";
    homepage = "https://github.com/HowardHinnant/date";
    platforms = platforms.linux;
    maintainers = with maintainers; [ ma27 ];
  };
}
