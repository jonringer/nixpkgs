{ lib
, buildPythonPackage
, fetchPypi
, isPy3k
, isPy36
, pythonOlder
, contextvars
, pytestCheckHook
, sphinx
}:

buildPythonPackage rec {
  pname = "curio";
  version = "1.2";
  disabled = pythonOlder "3.6";

  src = fetchPypi {
    inherit pname version;
    sha256 = "90f320fafb3f5b791f25ffafa7b561cc980376de173afd575a2114380de7939b";
  };

  checkInputs = [ pytestCheckHook sphinx ]
    ++ lib.optionals isPy36 [ contextvars ];

  disabledTests = [
    "aside"               # times out
    "ssl_outgoing"        # touches network
  ] ++ lib.optionals (pythonOlder "3.7") [
    # unsupported syntax <3.7
    "asyncio_consumer"
    "uevent_get_asyncio"
  ];

  __darwinAllowLocalNetworking = true;

  meta = with lib; {
    homepage = "https://github.com/dabeaz/curio";
    description = "Library for performing concurrent I/O with coroutines in Python 3";
    license = licenses.bsd3;
    maintainers = [ maintainers.marsam ];
  };
}
