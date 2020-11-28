{ stdenv, fetchFromGitHub, glibcLocales
, cmake, python3

, eigen
, gtest
, grpc
, howard-hinnant-date
, protobuf
, libpng
, zlib
, flatbuffers
}:

let
  python3-env = python3.withPackages (ps: with ps; [ flake8 ]);
in
stdenv.mkDerivation rec {
  pname = "onnxruntime";
  version = "1.5.3";

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "onnxruntime";
    rev = "v${version}";
    sha256 = "03w1nbydf76kxh1yfy87c65ydc40ywk2zysjpch0s4gspc3vbyyz";
  };

  # TODO: build server, and move .so's to lib output
  outputs = [ "out" "dev" ];

  nativeBuildInputs = [
    cmake
    python3-env # for shared-lib or server
  ];

  buildInputs = [
    eigen
    protobuf
    grpc
    gtest
    howard-hinnant-date
    # technically optional, but highly recommended
    libpng
    zlib
  ];

  # these are not able to be passed as cmake flags, unfortunately
  postPatch = ''
    rm -r cmake/external/date
    ln -svf ${howard-hinnant-date.src} cmake/external/date
    rm -r cmake/external/flatbuffers
    ln -svf ${flatbuffers.src} cmake/external/flatbuffers
    rm -r cmake/external/onnx
    ln -svf ${python3.pkgs.onnx.src} cmake/external/onnx
  '';

  cmakeDir = "../cmake";

  cmakeFlags = [
    # pull gtest from build environment, instead of vendored submodule
    "-Donnxruntime_PREFER_SYSTEM_LIB=ON"
    "-Donnxruntime_USE_OPENMP=ON"
    "-Donnxruntime_BUILD_SHARED_LIB=ON"
    "-Donnxruntime_ENABLE_LTO=ON"
  ];

  # ContribOpTest.StringNormalizerTest sets locale to en_US.UTF-8"
  preCheck = stdenv.lib.optionalString stdenv.isLinux ''
    export LOCALE_ARCHIVE="${glibcLocales}/lib/locale/locale-archive"
  '';
  doCheck = true;

  postInstall = ''
    rm -r $out/bin   # ctest runner
  '';

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "Cross-platform, high performance scoring engine for ML models";
    longDescription = ''
      ONNX Runtime is a performance-focused complete scoring engine
      for Open Neural Network Exchange (ONNX) models, with an open
      extensible architecture to continually address the latest developments
      in AI and Deep Learning. ONNX Runtime stays up to date with the ONNX
      standard with complete implementation of all ONNX operators, and
      supports all ONNX releases (1.2+) with both future and backwards
      compatibility.
    '';
    homepage = "https://github.com/microsoft/onnxruntime";
    changelog = "https://github.com/microsoft/onnxruntime/releases";
    # https://github.com/microsoft/onnxruntime/blob/master/BUILD.md#architectures
    platforms = platforms.unix;
    license = licenses.mit;
    maintainers = with maintainers; [ jonringer ];
  };

}
