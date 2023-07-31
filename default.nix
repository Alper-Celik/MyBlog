{ stdenvNoCC, hugo, src, theme }:
stdenvNoCC.mkDerivation {
  name = "Alper Celik's blog";
  buildInputs = [ hugo ];
  inherit src;
  buildPhase = ''
    mkdir themes
    ln -sf ${theme} themes/theme
    hugo --destination=$out 
  '';
  shellHook = ''
    mkdir themes
    ln -sf ${theme} themes/theme
  '';
}
