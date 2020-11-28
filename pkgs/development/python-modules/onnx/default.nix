{ lib
, buildPythonPackage
, fetchFromGitHub
, pythonOlder
, isPy27
, cmake
, protobuf
, numpy
, six
, typing-extensions
, typing
, pybind11
, pytestrunner
, pytestCheckHook
, nbval
, tabulate
}:

buildPythonPackage rec {
  pname = "onnx";
  version = "1.8.0";

  # Due to Protobuf packaging issues this build of Onnx with Python 2 gives
  # errors on import.
  # Also support for Python 2 will be deprecated from Onnx v1.8.
  disabled = isPy27;

  src = fetchFromGitHub {
    owner = "onnx";
    repo = "onnx";
    rev = "v${version}";
    sha256 = "0hhvdalcjsf3rdpplccsqw1wmbrz19r706z1xjs9x8cggmcg83gc";
  };

  nativeBuildInputs = [
    cmake
    pytestrunner # setup_requires will fail if not present
  ];

  buildInputs = [ pybind11 ];

  propagatedBuildInputs = [
    protobuf
    numpy
    six
    typing-extensions
  ] ++ lib.optional (pythonOlder "3.5") [ typing ];

  checkInputs = [
    pytestCheckHook
    nbval
    tabulate
  ];

  postPatch = ''
    patchShebangs tools/protoc-gen-mypy.py
  '';

  preBuild = ''
    export MAX_JOBS=$NIX_BUILD_CORES
  '';

  # The executables are just utility scripts that aren't too important
  postInstall = ''
    rm -r $out/bin
  '';

  preCheck = ''
    export HOME=$TMPDIR
    cd onnx/test
  '';

  disabledTests = [
    "OnnxBackendRealModelTest" # tries to download models from s3
  ];

  # The setup.py does all the configuration
  dontUseCmakeConfigure = true;

  meta = with lib; {
    homepage    = "http://onnx.ai";
    description = "Open Neural Network Exchange";
    license     = licenses.mit;
    maintainers = with maintainers; [ acairncross jonringer ];
  };
}
