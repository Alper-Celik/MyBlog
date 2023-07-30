{ stdenvNoCC, hugo, src, holy-theme }:
stdenvNoCC.mkDerivation {
  name = "Alper Çelik's blog";
  buildInputs = [ hugo ];
  inherit src;
  buildPhase = ''
    mkdir themes
    ln -sf ${holy-theme} themes/holy
    hugo --destination=$out 
  '';
  shellHook = ''
    mkdir themes
    ln -sf ${holy-theme} themes/holy
  '';
}
