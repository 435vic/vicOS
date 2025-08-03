pkgs: rec {
  definitions = with pkgs.vimPlugins; {
    catppuccin = {
      variants = ["latte" "frappe" "macchiato" "mocha"];
      package = catppuccin-nvim;
    };

    tokyonight = {
      variants = ["day" "night" "storm" "moon"];
      package = tokyonight-nvim;
    };

    rose-pine = {
      variants = ["dawn" "moon"];
      package = rose-pine;
    };

    nordic = {
      variants = [];
      package = nordic-nvim;
    };
  };

  pkgFor = colorscheme: let
    inherit (builtins) elemAt match warn elem;
    parts = match "(.+)-([^-]+)" colorscheme;
    base =
      if parts != null
      then elemAt parts 0
      else null;
    variant =
      if parts != null
      then elemAt parts 1
      else null;

    baseDef = definitions.${colorscheme} or null;
    variantDef = definitions.${base} or null;

    variantPackageWarn = warn "Unknown colorscheme ${colorscheme}, falling back to ${base}" variantDef.package;
  in
    if parts != null && variantDef != null
    then
      if elem variant variantDef.variants
      then variantDef.package
      else variantPackageWarn
    else if baseDef != null
    then baseDef.package
    else throw "Unknown colorscheme ${colorscheme}";

  index = with pkgs.lib;
    pipe definitions [
      (mapAttrsToList (name: def: {
        "${def.package.pname}" = (map (variant: "${name}-${variant}") def.variants) ++ [name];
      }))
      mergeAttrsList
    ];
}
