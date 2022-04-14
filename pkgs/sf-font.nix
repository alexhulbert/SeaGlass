{ stdenv, fetchurl, lib }:

stdenv.mkDerivation rec {
  version = "2015-06-25";
  name = "font-system-san-francisco-${version}";
  at = "bd895dae758c135851805087f68bef655fdc160c";

  srcs = [
    (fetchurl {
      url = "https://raw.githubusercontent.com/supermarin/YosemiteSanFranciscoFont/${at}/System%20San%20Francisco%20Display%20Bold.ttf";
      name = "system-san-francisco-display-bold.ttf";
      sha256 = "08472gs6yhqzcrnhw8k2flh0sspj6bma55b295pnx1ynd2cnj8h9";
    })
    (fetchurl {
      url = "https://raw.githubusercontent.com/supermarin/YosemiteSanFranciscoFont/${at}/System%20San%20Francisco%20Display%20Regular.ttf";
      name = "system-san-francisco-display-regular.ttf";
      sha256 = "0hyqs93k69ph4pddkzjxp1hn92mqmzsp97kjwgq31j82n5gsssi3";
    })
    (fetchurl {
      url = "https://raw.githubusercontent.com/supermarin/YosemiteSanFranciscoFont/${at}/System%20San%20Francisco%20Display%20Thin.ttf";
      name = "system-san-francisco-display-thin.ttf";
      sha256 = "0qldanvywkpzhk29rkz1py6dkjggxmqj62qkpfxm138gv3pjf44a";
    })
    (fetchurl {
      url = "https://raw.githubusercontent.com/supermarin/YosemiteSanFranciscoFont/${at}/System%20San%20Francisco%20Display%20Ultralight.ttf";
      name = "system-san-francisco-display-ultralight.ttf";
      sha256 = "0rhy48ihkscvdj5lgjf9w1zf5a5x25mf3qs3pcb4a58nyb08y8vy";
    })
  ];

  phases = [ "unpackPhase" "installPhase" ];

  sourceRoot = "./";

  unpackCmd = ''
    ttfName=$(basename $(stripHash $curSrc))
    echo "ttfname: $ttfName"
    cp $curSrc ./$ttfName
  '';

  installPhase = ''
    mkdir -p $out/share/fonts/system-san-francisco
    cp *.ttf $out/share/fonts/system-san-francisco
  '';

  outputHashAlgo = "sha256";
  outputHashMode = "recursive";
  outputHash = "1h8zygx8sjp3rvyn5rgzp69vm3dfhh97nrzg9llbc5j08ddgkp8m";

  meta = {
    description = "System San Francisco Font by Apple";
    homepage = https://github.com/supermarin/YosemiteSanFranciscoFont;
    license = lib.licenses.asl20;
    platforms = lib.platforms.all;
    maintainers = [];
  };
}
