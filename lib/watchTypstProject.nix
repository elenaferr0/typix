{
  inferTypstProjectOutput,
  lib,
  linkVirtualPaths,
  pkgs,
  typst,
  typstOptsFromArgs,
  unsetSourceDateEpoch,
}: args @ {
  fontPaths ? [],
  forceVirtualPaths ? false,
  typstSource ? "main.typ",
  typstWatchCommand ? "typst watch",
  virtualPaths ? [],
  ...
}: let
  inherit (builtins) removeAttrs;
  inherit (lib) optionalString;
  inherit (lib.strings) concatStringsSep toShellVars;

  typstOptsString = args.typstOptsString or (typstOptsFromArgs args);
  typstOutput =
    args.typstOutput
    or (inferTypstProjectOutput (
      {inherit typstSource;} // args
    ));

  unsetSourceDateEpochHook = builtins.readFile "${unsetSourceDateEpoch}/nix-support/setup-hook";

  cleanedArgs = removeAttrs args [
    "fontPaths"
    "forceVirtualPaths"
    "scriptName"
    "text"
    "typstOpts"
    "typstOptsString"
    "typstOutput"
    "typstSource"
    "typstWatchCommand"
    "virtualPaths"
  ];
in
  pkgs.writeShellApplication (cleanedArgs
    // {
      name = args.scriptName or args.name or "typst-watch";

      runtimeInputs =
        (args.runtimeInputs or [])
        ++ [
          pkgs.coreutils
          typst
        ];

      text =
        optionalString (fontPaths != []) ''
          export TYPST_FONT_PATHS=${concatStringsSep ":" fontPaths}
        ''
        + optionalString (virtualPaths != []) (linkVirtualPaths {
          inherit virtualPaths forceVirtualPaths;
        })
        + unsetSourceDateEpochHook
        + ''

          ${toShellVars {inherit typstOutput typstSource;}}
          out=''${1:-''${typstOutput:?not defined}}
          mkdir -p "$(dirname "$out")"

          unsetSourceDateEpoch

          ${typstWatchCommand} ${typstOptsString} "$typstSource" "$out"
        '';
    })
