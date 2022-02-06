{ stdenv
, keras
, nose
, numba
, numpy
, pynndescent
, pytestCheckHook
, scikit-learn
, scipy
, tensorflow
, tqdm
, umap-learn
}:

stdenv.mkDerivation rec {
  name = "umap-tests";

  inherit (umap-learn) src;

  dontBuild = true;
  dontInstall = true;

  doCheck = true;
  checkInputs = [
    keras
    nose
    numba
    numpy
    pynndescent
    pytestCheckHook
    scikit-learn
    scipy
    tensorflow
    tqdm
    umap-learn
  ];

  preCheck = ''
    export HOME=$TMPDIR
  '';

  # only test a subset, they are very expensive
  pytestFlagsArray = [
    "umap/tests/test_umap_ops.py"
  ];

  disabledTests = [
    # Plot functionality requires additional packages.
    # These test also fail with 'RuntimeError: cannot cache function' error.
    "test_umap_plot_testability"
    "test_plot_runs_at_all"

    # Flaky test. Fails with AssertionError sometimes.
    "test_sparse_hellinger"

    # tensorflow maybe incompatible? https://github.com/lmcinnes/umap/issues/821
    "test_save_load"
  ];

  installPhase = ''
    touch $out
  '';
}

