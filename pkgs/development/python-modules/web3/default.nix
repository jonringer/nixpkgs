{ lib
, buildPythonPackage
, fetchFromGitHub
, aiohttp
, eth-abi
, eth-account
, eth-hash
, eth-typing
, eth-utils
, jsonschema
, hexbytes
, ipfshttpclient
, lru-dict
, protobuf
, pytestCheckHook
, requests
, websockets
}:

buildPythonPackage rec {
  pname = "web3";
  version = "ca662c879e95e9e184d9dfdb78855492e1d7db23";

  src = fetchFromGitHub {
    owner = "ethereum";
    repo = "web3.py";
    rev = version;
    sha256 = "sha256-OeL4Lg1/ZCrEZQkZvCiGzcIn1X+F/BPBA4eFwF0SBoo=";
  };

  propagatedBuildInputs = [
    aiohttp
    eth-abi
    eth-account
    eth-hash
    eth-typing
    eth-utils
    hexbytes
    ipfshttpclient
    jsonschema
    lru-dict
    protobuf
    requests
    websockets
  ];

  # almost all tests requires `eth-tester`, which is horribly out-of-date from the rest
  # of the ethereum ecosystem
  doCheck = false;
  checkInputs = [
    pytestCheckHook
  ];

  meta = with lib; {
    description = "A python interface for interacting with the Ethereum blockchain and ecosystem.";
    homepage = "https://web3py.readthedocs.io";
    license = licenses.mit;
    maintainers = with maintainers; [ nrdxp ];
  };
}
