{ lib
, buildPythonPackage
, fetchFromGitHub
, eth-utils
, eth-typing
, hypothesis
, parsimonious
, pytestCheckHook
}:

buildPythonPackage rec {
  pname = "eth-abi";
  version = "3.0.0";

  src = fetchFromGitHub {
    owner = "ethereum";
    repo = "eth-abi";
    rev = "v${version}";
    sha256 = "sha256-qiuyGVOy+n8l3jSqwMGnBXcDrOxIiJ0lNP4lq/EQEhU=";
  };

  propagatedBuildInputs = [
    eth-utils
    eth-typing
    parsimonious
  ];

  checkInputs = [
    hypothesis
    pytestCheckHook
  ];

  disabledTests = [
    # fails due to different __repr__ output between python interpreters
    "test_get_abi_strategy_returns_certain_strategies_for_known_type_strings"
  ];

  pythonImportsCheck = [ "eth_abi" ];

  meta = with lib; {
    description = "Utilities for working with Ethereum ABI definitions, especially encoding and decoding";
    homepage = "https://github.com/ethereum/eth-abi";
    license = licenses.mit;
    maintainers = with maintainers; [ jonringer ];
  };
}
