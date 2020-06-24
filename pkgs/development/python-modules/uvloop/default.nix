{ lib
, stdenv
, buildPythonPackage
, fetchFromGitHub
, pyopenssl
, libuv
, psutil
, isPy27
, cython
, libtool
, autoconf
, automake
, CoreServices
, ApplicationServices
# Check Inputs
, pytestCheckHook
# , pytest-asyncio
}:

buildPythonPackage rec {
  pname = "uvloop";
  version = "unstable-2020-04-25";
  disabled = isPy27;

  src = fetchFromGitHub {
    owner = "MagicStack";
    repo = pname;
    rev = "465717fdaf2cb260a1c4b230925a537afc22cedb";
    sha256 = "1kgc2y08fndh4696rsd2ngdbpk2d94vd79fx1zf2p9816s0lbska";
    fetchSubmodules = true;
  };

  patches = lib.optional stdenv.isDarwin ./darwin_sandbox.patch;

  postPatch = ''
    substituteInPlace setup.py \
      --replace "/bin/sh" "sh"
  '';

  nativeBuildInputs = [ cython libtool automake autoconf ];

  buildInputs = [
    libuv
  ] ++ lib.optionals stdenv.isDarwin [ CoreServices ApplicationServices ];

  pythonImportsCheck = [
    "uvloop"
    "uvloop.loop"
  ];

  dontUseSetuptoolsCheck = true;
  checkInputs = [ pytestCheckHook pyopenssl psutil ];

  pytestFlagsArray = [
    # from pytest.ini, these are NECESSARY to prevent failures
    "--capture=no"
    "--assert=plain"
    "--tb=native"
    # ignore code linting tests
    "--ignore=tests/test_sourcecode.py"
  ];

  disabledTests = [
    "test_sock_cancel_add_reader_race"  # asyncio version of test is supposed to be skipped but skip doesn't happen. uvloop version runs fine
  ];

  # force using installed/compiled uvloop vs source by moving tests to temp dir
  preCheck = ''
    export TEST_DIR=$(mktemp -d)
    cp -r tests $TEST_DIR
    pushd $TEST_DIR
  '' + lib.optionalString stdenv.isDarwin ''
    # Some tests fail on Darwin
    rm tests/test_[stu]*.py
  '';
  postCheck = ''
    popd
  '';

  # Some of the tests use localhost networking.
  __darwinAllowLocalNetworking = true;

  meta = with lib; {
    description = "Fast implementation of asyncio event loop on top of libuv";
    homepage = "https://github.com/MagicStack/uvloop";
    license = licenses.mit;
    maintainers = with maintainers; [ costrouc ];
  };
}
