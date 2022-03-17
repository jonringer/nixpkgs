{ lib
, buildPythonPackage
, fetchFromGitHub
, eth-utils
, eth-typing
, factory_boy
, hypothesis
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "eth-keys";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "ethereum";
    repo = "eth-keys";
    rev = "v${version}";
    sha256 = "sha256-jG/jJPM4t3z6UQIdc8L6y0DxZiGx5pVuGL8XwbIt60o=";
  };

  propagatedBuildInputs = [
    eth-utils
    eth-typing
  ];

  checkInputs = [
    factory_boy
    hypothesis
    pytestCheckHook
  ];

  disabledTestPaths = [
    # asn1tools is not available in nixpkgs
    "tests/core/test_utils_der.py"
    # coincursive not available in nixpkgs
    "tests/backends/test_native_backend_against_coincurve.py"
  ];

  pythonImportsCheck = [ "eth_keys" ];

  meta = with lib; {
    description = "Common API for Ethereum key operations";
    homepage = "https://github.com/ethereum/eth-keys";
    license = licenses.mit;
    maintainers = with maintainers; [ jonringer ];
  };
}
