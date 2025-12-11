{
    inputs = {
        # Get nixpkgs-unstable (see https://status.nixos.org)
        nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

        # Flake-Utils
        flake-utils.url = "github:numtide/flake-utils";

        # Rust Overlay
        rust-overlay = {
            url = "github:oxalica/rust-overlay";
            inputs = { nixpkgs.follows = "nixpkgs-unstable"; };
        };
    };

    outputs = {
        self, flake-utils, nixpkgs-unstable, rust-overlay
    }:
        flake-utils.lib.eachDefaultSystem (system:
            let
                ### Core ###########################################################################

                # Define pkgs as nixpkgs with some additional overlays
                pkgs = import nixpkgs-unstable {
                    inherit system;

                    # Define overlays
                    overlays = [ (import rust-overlay) ];
                };

                # Load Rust toolchain from file
                rust-s = pkgs.pkgsBuildHost.rust-bin
                    .fromRustupToolchainFile ./rust-toolchain.toml;
                    # .selectLatestNightlyWith (toolchain: toolchain.default);

                # Load Rust nightly toolchain
                rust-n = pkgs.rust-bin
                    # .fromRustupToolchainFile ./rust-toolchain.toml;
                    .selectLatestNightlyWith (toolchain: toolchain.default);

                # Wrapper script to make cargo nightly accessible via `cargo-n`.
                cargo-n = pkgs.writeShellScriptBin "cargo-n" ''
                    PATH=${rust-n}/bin:$PATH
                    exec cargo "$@"
                '';

                cargo-workspace-unused-pub = pkgs.rustPlatform.buildRustPackage rec {
                    pname = "cargo-workspace-unused-pub";
                    version = "0.1.0"; # Check latest version

                    src = pkgs.fetchCrate {
                        inherit pname version;
                        hash = "sha256-T0neI46w2u4hD1QvpF/qsCt8oH2bdyck8s9iNKMikCE="; # Replace with actual hash
                    };

                    cargoHash = "sha256-FsvNvZ6RlASEhf1N6W3ogd45P6NBQF8EurkWCK/56Ow="; # Replace with actual hash

                    meta = with pkgs.lib; {
                        description = "Detects unused pub items in Rust workspace";
                        homepage = "https://crates.io/crates/cargo-workspace-unused-pub";
                        license = licenses.mit;
                        maintainers = [];
                    };
                };


                ### Dependencies ###################################################################

                devPackages = with pkgs; [
                    # Rust stable and cargo via wrapper
                    rust-s
                    cargo-n

                    # Additional "cargo" commands
					cargo-hakari	   # workspace hack
                    cargo-expand       # macro expansion/inspection
                    cargo-audit        # dependency vulnerability check
                    cargo-deny         # dependency licence check
                    cargo-udeps        # dependency inspection
                    cargo-machete      # -- " --
                    cargo-shear        # -- " --
                    cargo-outdated     # dependency updates
                    cargo-llvm-lines   # number of lines of LLVM IR
                    cargo-bloat        # find out what takes most of the space in executable
                    cargo-features-manager
                    measureme          # Rustc self-profiling (incl: crox, flamegraph, summarize)

                    cargo-depgraph     # dependency graph
                    cargo-insta        # end-to-end testing/snapshot management
                    cargo-workspace-unused-pub

                    # Terminal Code Checker
                    bacon

                    # Graphviz: Graph visualization library
                    graphviz                    # for use with "cargo-depgraph"

                    # Diesel CLI
                    diesel-cli

                    # Tokei: Count lines of code (LoC)
                    tokei

                    # Programs for load testing
                    oha

                    # Pre-Commit (Framework for managing pre-commit hooks)
                    pre-commit

                    # NATS.io tools
                    natscli
                    nats-top

                    # SpiceDB CLI (zed)
                    spicedb-zed
                    spicedb

                    # Pest LSP
                    pest-ide-tools

                    # Just (make alternative)
                    just

                    # Docker image inspection
                    dive

                    # Nix
                    nil
                ];


                ####################################################################################

            in with pkgs;
            rec {
                ### Dev Shell ######################################################################
                devShells.default = mkShell rec {
                    # Development packages
                    packages = devPackages;

                    # Configure pre-commit on shell-instantiation
                    shellHook = ''
                        pre-commit install -f --hook-type pre-commit
                        pre-commit install -f --hook-type commit-msg
                    '';

                    # Environment Variables
                    # RUST_BACKTRACE = "full";
                    # LD_LIBRARY_PATH = "${lib.makeLibraryPath buildInputs}";
                };

                ####################################################################################
            }
        );
}
