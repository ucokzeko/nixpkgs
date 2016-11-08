{ nixpkgs ? <nixpkgs>
, systems ? [ "x86_64-linux" "armv7l-linux" ] }:

let
  lib = (import nixpkgs {}).lib;
in lib.genAttrs systems (system:
  let pkgs = import nixpkgs { inherit system; };
  in {
    build = pkgs.domoticz;
  }
)
