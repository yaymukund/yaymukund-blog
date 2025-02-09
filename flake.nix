{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { flake-utils
    , nixpkgs
    , ...
    }: flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs { system = system; };
    in
    {
      devShells.default = pkgs.mkShell {
        name = "yaymukund-blog-devshell";
        packages = [ pkgs.zola ];
      };
    });
}
