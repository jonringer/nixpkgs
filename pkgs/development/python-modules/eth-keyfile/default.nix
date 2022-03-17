{ lib
, buildPythonPackage
, fetchPypi
, eth-utils
, eth-keys
, pycryptodome
}:

buildPythonPackage rec {
  pname = "eth-keyfile";
  version = "0.6.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "d30597cdecb8ccd3b56bb275cd86fcdc7a279f86eafa92ddc49f66512f0bff67";
  };

  postPatch = ''
    # setuptools-markdown not available in nixpkgs
    sed -i -e '/setuptools-markdown/d' setup.py
  '';

  propagatedBuildInputs = [
    eth-utils
    eth-keys
    pycryptodome
  ];

  pythonImportsCheck = [ "eth_keyfile" ];

  meta = with lib; {
    description = "A library for handling the encrypted keyfiles used to store ethereum private keys";
    homepage = "https://github.com/ethereum/eth-keyfile";
    license = licenses.mit;
    maintainers = with maintainers; [ jonringer ];
  };
}
