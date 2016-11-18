{fetchFromGitHub, stdenv, cmake, boost, zlib, curl, git, openzwave, libudev, pkgconfig}:

stdenv.mkDerivation {
  name = "domoticz-3.5877";

  src = fetchFromGitHub {
    owner = "domoticz";
    repo = "domoticz";
    rev = "6fdf902ea89c835a338c9aadcf8dd26c4b7a6242";
    sha256 = "0h6lc3hg5ha0g4q91v1q23hsa67kyr3r0x2ag5k0rdxkv8k9fdf8";
  };

  buildInputs = [ cmake boost zlib curl git openzwave libudev pkgconfig ];

  cmakeFlags = [ "-DUSE_STATIC_BOOST=NO" "-DUSE_STATIC_OPENZWAVE=NO" ];
}
