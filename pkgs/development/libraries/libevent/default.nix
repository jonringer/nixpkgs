{ lib, stdenv, findutils, fixDarwinDylibNames, cmake, fetchpatch, doxygen
# for the cmake build, libevent_openssl is expected to build in all cases
, sslSupport ? true, openssl, mbedtls }:

assert sslSupport -> openssl != null;

stdenv.mkDerivation rec {
  pname = "libevent";
  version = "2.1.12";

  src = builtins.fetchGit {
    url =
      "git@github.com:jonringer/libevent.git";
    rev = "dc0c22f615214b90610b66490fc6ea5ce04d6360";
    ref = "use-gnu-install";
  };

  preConfigure = lib.optionalString
    (lib.versionAtLeast stdenv.hostPlatform.darwinMinVersion "11") ''
      MACOSX_DEPLOYMENT_TARGET=10.16
    '';

  outputs = [ "out" "dev" ];

  outputBin = "dev";
  propagatedBuildOutputs = [ "out" ];

  nativeBuildInputs = [ cmake doxygen ]
    ++ lib.optional stdenv.hostPlatform.isDarwin fixDarwinDylibNames;

  buildInputs = [ ] ++ lib.optionals sslSupport [ mbedtls openssl]
    ++ lib.optional stdenv.isCygwin findutils;

  cmakeFlags = [
    "-DDOXYGEN_GENERATE_MAN=YES"
    "-DDOXYGEN_GENERATE_HTML=YES"
  ];

  doCheck = false; # needs the net

  meta = with lib; {
    description = "Event notification library";
    longDescription = ''
      The libevent API provides a mechanism to execute a callback function
      when a specific event occurs on a file descriptor or after a timeout
      has been reached.  Furthermore, libevent also support callbacks due
      to signals or regular timeouts.

      libevent is meant to replace the event loop found in event driven
      network servers.  An application just needs to call event_dispatch()
      and then add or remove events dynamically without having to change
      the event loop.
    '';
    homepage = "https://libevent.org/";
    license = licenses.bsd3;
    platforms = platforms.all;
  };
}
