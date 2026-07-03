{
  description = "Development shell for zmk-driver-iqs9151";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    zmk = {
      url = "github:zmkfirmware/zmk/v0.3.0";
      flake = false;
    };
    zephyr = {
      url = "git+https://github.com/zmkfirmware/zephyr.git?ref=refs/heads/v3.5.0%2Bzmk-fixes";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, zmk, zephyr }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      forAllSystems = f:
        nixpkgs.lib.genAttrs systems (system:
          f (import nixpkgs {
            inherit system;
          }));
    in
    {
      devShells = forAllSystems (pkgs:
        let
          pythonEnv = pkgs.python3.withPackages (ps: with ps; [
            anytree
            canopen
            cbor
            colorama
            intelhex
            kconfiglib
            natsort
            packaging
            progress
            psutil
            pyelftools
            pylink-square
            pyocd
            pykwalify
            pyserial
            pytest
            pyyaml
            requests
            setuptools
            tabulate
            west
            wheel
          ]);

          optionalZephyrSdk = nixpkgs.lib.optionals (pkgs ? zephyr-sdk) [
            pkgs.zephyr-sdk
          ];

          iqs9151Test = pkgs.writeShellApplication {
            name = "iqs9151-test";
            runtimeInputs = [ pythonEnv ];
            text = ''
root="$ZMK_DRIVER_IQS9151_ROOT"
if [ -z "$root" ]; then
  root="$PWD"
fi

if [ "$#" -gt 0 ]; then
  platform="$1"
else
  platform="native_sim_64"
fi

python "$ZEPHYR_BASE/scripts/twister" -T "$root/tests/iqs9151_work_cb" -p "$platform" --inline-logs
'';
          };
        in
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              ccache
              clang-tools
              cmake
              dtc
              git
              gnumake
              gperf
              iqs9151Test
              ninja
              pythonEnv
            ] ++ optionalZephyrSdk;

            shellHook = ''
export ZMK_DRIVER_IQS9151_ROOT="$PWD"
export ZEPHYR_BASE="${zephyr}"
export ZMK_APP_DIR="${zmk}/app"
export ZEPHYR_TOOLCHAIN_VARIANT="host"

echo "zmk-driver-iqs9151 dev shell"
echo "ZEPHYR_BASE=$ZEPHYR_BASE"
echo "ZMK_APP_DIR=$ZMK_APP_DIR"
echo "ZEPHYR_TOOLCHAIN_VARIANT=$ZEPHYR_TOOLCHAIN_VARIANT"
echo "Run: iqs9151-test"
'';
          };
        });
    };
}
