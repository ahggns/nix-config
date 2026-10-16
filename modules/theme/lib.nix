{ lib, pkgs }:

let
  ah = import ../lib.nix { inherit lib; };

  baseNames = map (i: "base0${i}") [
    "0"
    "1"
    "2"
    "3"
    "4"
    "5"
    "6"
    "7"
    "8"
    "9"
    "A"
    "B"
    "C"
    "D"
    "E"
    "F"
  ];

  themes = lib.listToAttrs (
    map (file: {
      name = lib.removeSuffix ".nix" (baseNameOf file);
      value = import file { inherit pkgs; };
    }) (ah.importDir ./themes)
  );

  channel = hex: i: lib.fromHexString (builtins.substring i 2 hex);
in
{
  inherit baseNames themes;

  resolve =
    cfg:
    let
      p = lib.genAttrs baseNames (n: cfg.palette.${n});
      stock = themes.${cfg.name} or null;
      isStock =
        stock != null && lib.all (n: lib.toLower p.${n} == lib.toLower stock.palette.${n}) baseNames;

      rgb = hex: {
        r = channel hex 1;
        g = channel hex 3;
        b = channel hex 5;
      };
      bg = rgb p.base00;
    in
    rec {
      inherit isStock;
      inherit (cfg) name;
      palette = p;

      native = if isStock then stock.native or { } else { };

      polarity = if (299 * bg.r + 587 * bg.g + 114 * bg.b) / 1000 < 128 then "dark" else "light";

      # standard base16 -> ANSI mapping
      named = with p; {
        black = base00;
        red = base08;
        green = base0B;
        yellow = base0A;
        blue = base0D;
        magenta = base0E;
        cyan = base0C;
        white = base05;
        orange = base09;
        brown = base0F;
        bright-black = base03;
        bright-white = base07;
      };
      ansi = with p; [
        base00
        base08
        base0B
        base0A
        base0D
        base0E
        base0C
        base05
        base03
        base08
        base0B
        base0A
        base0D
        base0E
        base0C
        base07
      ];
    };
}
