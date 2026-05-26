{
  description = "ferment — a thin Mutagen wrapper that ferments your file changes";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        # NOTE: nixpkgs ships a mutagen; for the latest, consider the
        # mutagen-io official tap or a custom overlay.
        mutagen = pkgs.mutagen or null;

        ferment = pkgs.stdenv.mkDerivation {
          pname = "ferment";
          version = "0.1.0";
          src = ./.;

          nativeBuildInputs = [ pkgs.makeWrapper ];

          # We don't compile; just install scripts and completions.
          dontBuild = true;

          installPhase = ''
            runHook preInstall

            install -Dm755 bin/ferment $out/bin/ferment

            # Completions
            if [ -f completions/_ferment ]; then
              install -Dm644 completions/_ferment $out/share/zsh/site-functions/_ferment
            fi
            if [ -f completions/ferment.bash ]; then
              install -Dm644 completions/ferment.bash $out/share/bash-completion/completions/ferment
            fi
            if [ -f completions/ferment.fish ]; then
              install -Dm644 completions/ferment.fish $out/share/fish/vendor_completions.d/ferment.fish
            fi

            # Ensure mutagen is on PATH at runtime
            ${if mutagen != null then ''
              wrapProgram $out/bin/ferment \
                --prefix PATH : ${pkgs.lib.makeBinPath [ mutagen ]}
            '' else ''
              echo "warn: mutagen not in nixpkgs for this system; user must provide it on PATH" >&2
            ''}

            runHook postInstall
          '';

          meta = with pkgs.lib; {
            description = "A thin Mutagen wrapper that ferments your file changes";
            homepage    = "https://github.com/mei28/ferment";
            license     = licenses.mit;
            platforms   = platforms.unix;
            mainProgram = "ferment";
          };
        };
      in
      {
        packages = {
          default = ferment;
          ferment = ferment;
        };

        apps.default = flake-utils.lib.mkApp { drv = ferment; };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            bash
            shellcheck
            bats
          ] ++ (if mutagen != null then [ mutagen ] else []);
        };
      });
}
