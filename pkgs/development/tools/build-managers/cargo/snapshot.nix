{ stdenv, fetchurl, zlib, makeWrapper, rustc }:

/* Cargo binary snapshot */

let snapshotDate = "2016-01-31";
in

with ((import ./common.nix) {
  inherit stdenv rustc;
  version = "snapshot-${snapshotDate}";
});

let snapshotHash = if stdenv.system == "i686-linux"
      then "7e2f9c82e1af5aa43ef3ee2692b985a5f2398f0a"
      else if stdenv.system == "x86_64-linux"
      then "4c03a3fd2474133c7ad6d8bb5f6af9915ca5292a"
      else if stdenv.system == "i686-darwin"
      then "4d84d31449a5926f9e7ceb344540d6e5ea530b88"
      else if stdenv.system == "x86_64-darwin"
      then "f8baef5b0b3e6f9825be1f1709594695ac0f0abc"
      else if onArm
      then "aa133041997d7dd7cb97a159c964308df5644d64"
      else throw "no snapshot for platform ${stdenv.system}";
    snapshotName = "cargo-nightly-${platform}.tar.gz";
    snapshotUrl = if onArm
      then "https://www.dropbox.com/sh/ewam0qujfdfaf19/AABV2xcEXf-5812XxAk-I9m7a/ARMv7/1.9.0-beta/cargo-0.11.0-beta-2016-04-21-867627c-arm-unknown-linux-gnueabihf-aa133041997d7dd7cb97a159c964308df5644d64.tar.gz?dl=1"
      else "https://static-rust-lang-org.s3.amazonaws.com/cargo-dist/${snapshotDate}/${snapshotName}";
    onArm = stdenv.system == "armv7l-linux";
in

stdenv.mkDerivation ({
  inherit name version meta passthru;

  src = fetchurl {
    url = snapshotUrl;
    sha1 = snapshotHash;
  };

  buildInputs = [ makeWrapper ];

  dontStrip = true;

  __propagatedImpureHostDeps = [
    "/usr/lib/libiconv.2.dylib"
    "/usr/lib/libssl.0.9.8.dylib"
    "/usr/lib/libcurl.4.dylib"
    "/System/Library/Frameworks/GSS.framework/GSS"
    "/System/Library/Frameworks/GSS.framework/Versions/Current"
    "/System/Library/PrivateFrameworks/Heimdal.framework/Heimdal"
    "/System/Library/PrivateFrameworks/Heimdal.framework/Versions/Current"
  ];

  installPhase = ''
    mkdir -p "$out"
    ${if onArm then ''cp -r * "$out"'' else ''./install.sh "--prefix=$out"''}
  '' + (if stdenv.isLinux then ''
    patchelf --interpreter "$(cat ${stdenv.cc}/nix-support/dynamic-linker)" \
             --set-rpath "${stdenv.cc.cc.lib}/lib/:${stdenv.cc.cc.lib}/lib64/:${zlib.out}/lib" \
             "$out/bin/cargo"
  '' else "") + postInstall;
} // (if onArm then { sourceRoot = "."; } else {}))
