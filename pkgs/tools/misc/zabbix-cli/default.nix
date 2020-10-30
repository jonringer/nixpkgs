{ fetchFromGitHub, lib, buildPythonApplication, requests }:

buildPythonApplication rec {
  pname = "zabbix-cli";
  version = "2.2.1";

  src = fetchFromGitHub {
    owner = "usit-gd";
    repo = "zabbix-cli";
    rev = version;
    sha256 = "0bb3vk5waxbs3b7xplmwdys713nhab7ks7scipwlx3s0pa9zlg0n";
  };

  propagatedBuildInputs = [ requests ];

  # argparse is part of the standardlib
  prePatch = ''
    substituteInPlace setup.py --replace "'argparse'," ""
  '';

  checkPhase = ''
    $out/bin/zabbix-cli --help > /dev/null
  '';

  meta = with lib; {
    description = "Command-line interface for Zabbix";
    homepage = src.meta.homepage;
    license = [ licenses.gpl3 ];
    maintainers = [ maintainers.womfoo ];
  };
}
