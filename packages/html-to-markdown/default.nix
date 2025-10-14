{ pkgs, inputs, ... }:
let
	system = pkgs.stdenv.hostPlatform.system;
in
	inputs.html-to-markdown.packages.${system}.html-to-markdown
