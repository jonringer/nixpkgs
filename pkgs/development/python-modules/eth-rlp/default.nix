{ lib
, buildPythonPackage
, fetchPypi
, eth-utils
, hexbytes
, rlp
}:

buildPythonPackage rec {
  pname = "eth-rlp";
  version = "0.3.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "f3263b548df718855d9a8dbd754473f383c0efc82914b0b849572ce3e06e71a6";
  };

  propagatedBuildInputs = [
    eth-utils
    hexbytes
    rlp
  ];

  pythonImportsCheck = [ "eth_rlp" ];

  meta = with lib; {
    description = "RLP definitions for common Ethereum objects";
    homepage = "https://github.com/ethereum/eth-rlp";
    license = licenses.mit;
    maintainers = with maintainers; [ jonringer ];
  };
}
