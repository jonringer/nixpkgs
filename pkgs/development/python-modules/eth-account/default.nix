{ lib
, buildPythonPackage
, fetchFromGitHub
, bitarray
, hexbytes
, eth-abi
, eth-keyfile
, eth-keys
, eth-utils
, eth-rlp
, hypothesis
, pytestCheckHook
, rlp
}:

buildPythonPackage rec {
  pname = "eth-account";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "ethereum";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-cjQvTKC4lDbKnAvbmnTGHQiJZsZFhXc/+UH5rUdlGxs=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace "bitarray>=1.2.1,<1.3.0" "bitarray"
  '';

  propagatedBuildInputs = [
    bitarray
    hexbytes
    eth-abi
    eth-keyfile
    eth-keys
    eth-rlp
    eth-utils
    rlp
  ];

  checkInputs = [
    hypothesis
    pytestCheckHook
  ];

  disabledTests = [
    # `ethers_cli` not available in nixpkgs
    "test_compatibility"
  ];

  pytestFlagsArray = [
    # avoid docs and other directories which have dependencies not available in nixpkgs
    "tests"
  ];

  meta = with lib; {
    description = "Account abstraction library for web3.py";
    homepage = "https://github.com/ethereum/eth-account";
    license = licenses.mit;
    maintainers = with maintainers; [ nrdxp ];
  };
}
