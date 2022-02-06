{ lib
, buildPythonPackage
, callPackage
, fetchFromGitHub
, numpy
, scikit-learn
, scipy
, numba
, pynndescent
, tqdm
}:

buildPythonPackage rec {
  pname = "umap-learn";
  version = "0.5.2";

  outputs = [ "out" "tests" ];

  src = fetchFromGitHub {
    owner = "lmcinnes";
    repo = "umap";
    rev = version;
    sha256 = "sha256-JfYuuE1BP+HdiEl7l01sZ/XXlEwHyAsLjK9nqhRd/3o=";
  };

  propagatedBuildInputs = [
    numpy
    scikit-learn
    scipy
    numba
    pynndescent
    tqdm
  ];

  postInstall = ''
    mv umap/tests $tests
  '';

  # do not run tests as part of initial build
  doCheck = false;
  passthru.tests = {
    # the tests are VERY resource intensive
    full-tests = callPackage ./tests.nix { };
    # for demonstration
    run-test-suite = callPackage ./test-suite.nix { };
  };

  pytestImportsCheck = [
    "umap"
  ];

  meta = with lib; {
    description = "Uniform Manifold Approximation and Projection";
    homepage = "https://github.com/lmcinnes/umap";
    license = licenses.bsd3;
    maintainers = [ maintainers.costrouc ];
  };
}
