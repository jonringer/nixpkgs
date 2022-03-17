{ lib
, buildPythonPackage
, fetchPypi
}:

buildPythonPackage rec {
  pname = "lru-dict";
  version = "1.1.7";

  src = fetchPypi {
    inherit pname version;
    sha256 = "45b81f67d75341d4433abade799a47e9c42a9e22a118531dcb5e549864032d7c";
  };

  pythonImportsCheck = [ "lru" ];

  meta = with lib; {
    description = "An Dict like LRU container";
    homepage = "https://github.com/amitdev/lru-dict";
    license = licenses.mit;
    maintainers = with maintainers; [ jonringer ];
  };
}
